param(
  [string]$Device = 'emulator-5554',
  [string]$Flutter = 'flutter',
  [string]$BackendRoot = (Join-Path $PSScriptRoot '..\..\meatshop'),
  [switch]$KeepEnvironment
)

$ErrorActionPreference = 'Stop'
$mobileRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendPath = (Resolve-Path $BackendRoot).Path
if (-not (Test-Path (Join-Path $backendPath 'docker-compose.yml'))) {
  throw 'Docker Compose do backend não encontrado.'
}
foreach ($port in @(9099, 3101)) {
  if (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue) {
    throw "A porta de testes $port já está em uso."
  }
}
$firebaseCommand = Get-Command firebase -ErrorAction Stop
$firebaseCli = Join-Path (Split-Path $firebaseCommand.Source) 'node_modules\firebase-tools\lib\bin\firebase.js'
if (-not (Test-Path $firebaseCli)) { throw 'Firebase CLI não encontrado.' }
$project = 'meatshop-e2e-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$runtime = Join-Path $env:TEMP $project
New-Item -ItemType Directory -Path $runtime | Out-Null
$password = 'E2e!' + [guid]::NewGuid().ToString('N')
$firebaseConfig = Join-Path $runtime 'firebase.json'
$composeFile = Join-Path $runtime 'compose.json'
$definesFile = Join-Path $runtime 'defines.json'
$firebaseProcess = $null
$composeCreated = $false
$originalLocation = Get-Location

function Wait-LocalEndpoint([string]$Uri) {
  $deadline = (Get-Date).AddMinutes(2)
  while ((Get-Date) -lt $deadline) {
    try {
      Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 2 | Out-Null
      return
    } catch { Start-Sleep -Milliseconds 500 }
  }
  throw "Serviço local não respondeu: $Uri"
}

try {
  @{ emulators = @{ auth = @{ host = '0.0.0.0'; port = 9099 }; ui = @{ enabled = $false }; singleProjectMode = $true } } |
    ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $firebaseConfig -Encoding UTF8
  $firebaseProcess = Start-Process -FilePath (Get-Command node).Source -WindowStyle Hidden -PassThru `
    -WorkingDirectory $runtime `
    -ArgumentList @("`"$firebaseCli`"", 'emulators:start', '--only', 'auth', '--project', 'demo-meatshop-e2e', '--config', "`"$firebaseConfig`"", '--non-interactive') `
    -RedirectStandardOutput (Join-Path $runtime 'firebase.out.log') `
    -RedirectStandardError (Join-Path $runtime 'firebase.err.log')
  Wait-LocalEndpoint 'http://127.0.0.1:9099/'
  $uids = @{}
  foreach ($role in @('admin', 'owner', 'client', 'delivery')) {
    $account = Invoke-RestMethod -Method Post `
      -Uri 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=local-e2e' `
      -ContentType 'application/json' `
      -Body (@{ email = "$role@meatshop.local"; password = $password; returnSecureToken = $true } | ConvertTo-Json)
    Invoke-RestMethod -Method Post `
      -Uri 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update?key=local-e2e' `
      -Headers @{ Authorization = 'Bearer owner' } -ContentType 'application/json' `
      -Body (@{ localId = $account.localId; emailVerified = $true } | ConvertTo-Json) | Out-Null
    $uids[$role] = $account.localId
  }
  $rawConfig = & docker compose --project-directory $backendPath config --format json
  if ($LASTEXITCODE -ne 0) { throw 'Falha ao ler a configuração do backend.' }
  $spec = ($rawConfig -join "`n") | ConvertFrom-Json
  $spec.name = $project
  $spec.services = [pscustomobject]@{
    db = $spec.services.db
    migrator = $spec.services.migrator
    chatbot = $spec.services.chatbot
    backend = $spec.services.backend
  }
  $spec.services | Add-Member -MemberType NoteProperty -Name 'address-fixture' -Value ([pscustomobject]@{
    image = 'meatshop-mobile-e2e-backend:dev'
    container_name = "$project-address-fixture"
    command = @('node', '/fixtures/address.cjs')
    restart = 'no'
    networks = @('default')
    volumes = @(@{ type = 'bind'; source = (Join-Path $PSScriptRoot 'local-address-fixture.cjs'); target = '/fixtures/address.cjs'; read_only = $true })
  })
  $spec.services.backend.depends_on | Add-Member -MemberType NoteProperty -Name 'address-fixture' -Value ([pscustomobject]@{ condition = 'service_started'; required = $true })
  foreach ($property in $spec.services.PSObject.Properties) {
    $property.Value.container_name = "$project-$($property.Name)"
    $property.Value.restart = 'no'
  }
  foreach ($property in $spec.volumes.PSObject.Properties) {
    $property.Value.name = "$project-$($property.Name)"
  }
  foreach ($property in $spec.networks.PSObject.Properties) {
    $property.Value.name = "$project-$($property.Name)"
  }
  $spec.services.db.ports = @()
  $spec.services.chatbot.ports = @()
  $spec.services.backend.ports = @(@{ target = 3001; published = '3101'; host_ip = '127.0.0.1'; protocol = 'tcp' })
  $spec.services.backend.image = 'meatshop-mobile-e2e-backend:dev'
  $spec.services.migrator.image = 'meatshop-mobile-e2e-backend:dev'
  foreach ($service in @($spec.services.backend, $spec.services.migrator)) {
    $settings = @{
      NODE_ENV = 'development'
      BRASIL_API_BASE_URL = 'http://address-fixture:8080/api'
      SEED_ENABLED = 'true'
      SEED_PASSWORD = $password
      SEED_ADMIN_FIREBASE_UID = $uids.admin
      SEED_OWNER_FIREBASE_UID = $uids.owner
      SEED_CLIENT_FIREBASE_UID = $uids.client
      SEED_DELIVERY_FIREBASE_UID = $uids.delivery
      FIREBASE_AUTH_EMULATOR_HOST = 'host.docker.internal:9099'
      FIREBASE_PROJECT_ID = 'demo-meatshop-e2e'
      FIREBASE_WEB_API_KEY = 'local-e2e'
      FIREBASE_SERVICE_ACCOUNT = ''
      FIREBASE_APP_CHECK_ENFORCED = 'false'
      RATE_LIMIT_MAX = '5000'
      PAYMENTS_ENABLED = 'false'
    }
    foreach ($entry in $settings.GetEnumerator()) {
      $service.environment | Add-Member -MemberType NoteProperty -Name $entry.Key -Value $entry.Value -Force
    }
  }
  $spec | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $composeFile -Encoding UTF8
  $composeCreated = $true
  & docker compose -f $composeFile -p $project build backend
  if ($LASTEXITCODE -ne 0) { throw 'Falha ao construir o backend de testes.' }
  & docker compose -f $composeFile -p $project up -d --no-build backend
  if ($LASTEXITCODE -ne 0) { throw 'Falha ao iniciar a infraestrutura isolada.' }
  Wait-LocalEndpoint 'http://127.0.0.1:3101/health'
  & docker compose -f $composeFile -p $project exec -T db psql -U meatshop_user -d meatshop -c "UPDATE business_hours SET is_open=true, opening_time='00:00:00', closing_time='23:59:59';"
  if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o horário da unidade sintética.' }
  @{
    MEATSHOP_LOCAL_E2E = 'true'
    MEATSHOP_ENV = 'development'
    MEATSHOP_API_URL = 'http://10.0.2.2:3101'
    MEATSHOP_E2E_PASSWORD = $password
    MEATSHOP_AUTH_EMULATOR_HOST = '10.0.2.2'
    MEATSHOP_AUTH_EMULATOR_PORT = '9099'
  } | ConvertTo-Json | Set-Content -LiteralPath $definesFile -Encoding UTF8
  Set-Location $mobileRoot
  & $Flutter test integration_test/local_backend_journey_test.dart -d $Device --dart-define-from-file=$definesFile --reporter expanded
  if ($LASTEXITCODE -ne 0) { throw 'A jornada de integração falhou.' }
  Write-Output 'Jornada local concluída com autenticação emulada, API e PostgreSQL reais.'
} finally {
  Set-Location $originalLocation
  if ($composeCreated) {
    & docker compose -f $composeFile -p $project logs --no-color backend 2>&1 |
      Set-Content -LiteralPath (Join-Path $runtime 'backend.log') -Encoding UTF8
    if (-not $KeepEnvironment) {
      & docker compose -f $composeFile -p $project down -v
    }
  }
  if ($firebaseProcess -and -not $KeepEnvironment) {
    Stop-Process -Id $firebaseProcess.Id -ErrorAction SilentlyContinue
  }
  Write-Output "Artefatos locais do teste: $runtime"
}

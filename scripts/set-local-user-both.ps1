param(
  [string]$Email = 'viniciusrodri0809@gmail.com',
  [string]$BackendRoot = (Join-Path $PSScriptRoot '..\..\meatshop'),
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Email)) { throw 'Informe o e-mail da conta.' }
$backendPath = (Resolve-Path -LiteralPath $BackendRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $backendPath 'docker-compose.yml'))) {
  throw 'Docker Compose do backend local nao encontrado.'
}

# Email is bound by psql, never interpolated into SQL.
$operation = if ($CheckOnly) {
@'
SELECT u.id, u.email, u.app_profile, d.status AS delivery_status,
       (SELECT count(*) FROM vehicles v WHERE v.delivery_person_id = d.id) AS vehicles
FROM users u LEFT JOIN delivery_persons d ON d.user_id = u.id
WHERE lower(u.email) = lower(:'target_email');
'@
} else {
@'
UPDATE users SET app_profile = 'BOTH'
WHERE lower(email) = lower(:'target_email') AND is_active = true
RETURNING id, email, app_profile;
'@
}

$sql = @'
BEGIN;
SELECT EXISTS(SELECT 1 FROM users
  WHERE lower(email) = lower(:'target_email') AND is_active = true) AS account_found
\gset
\if :account_found
'@ + [Environment]::NewLine + $operation + [Environment]::NewLine + @'
COMMIT;
\else
ROLLBACK;
\echo Conta ativa nao encontrada. Nenhuma alteracao realizada.
\quit 1
\endif
'@

$sql | docker compose --project-directory $backendPath exec -T db psql -X -U meatshop_user -d meatshop -v ON_ERROR_STOP=1 -v "target_email=$($Email.Trim())"
if ($LASTEXITCODE -ne 0) { throw 'A operacao nao foi concluida.' }
if (-not $CheckOnly) {
  Write-Host 'Perfil BOTH aplicado. Saia e entre novamente no mobile.'
  Write-Host 'Para aceitar entregas, conclua o cadastro de entregador e veiculo no aplicativo.'
}

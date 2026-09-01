# Fase 1 — Fundação da API Flutter

## Objetivo

Fornecer uma única base técnica para todos os repositórios remotos do mobile. Esta fase não migra telas nem substitui os fluxos Firebase existentes; ela prepara o corte gradual das próximas fases sem escrita dupla.

## Composição

```text
ApiFoundation
  ├── ApiConfig
  ├── JsonHttpTransport
  ├── SecureSessionStore
  ├── BackendSessionRefresher
  ├── SessionCoordinator
  ├── ApiClient
  └── BackendConnectionRepository
```

- `JsonHttpTransport` é a única camada que conhece `package:http`.
- `SecureSessionStore` é a única camada que persiste tokens.
- `SessionCoordinator` restaura, salva, limpa e renova a sessão.
- `ApiClient` adiciona Bearer token, tenta refresh uma vez após `401` e repete a requisição uma vez.
- Providers devem depender de contratos em `lib/data/repositories`, nunca de classes em `lib/infra`.

## Configuração por ambiente

A URL não possui fallback silencioso. Isso evita distribuir um build apontando acidentalmente para o ambiente errado.

```powershell
flutter run --dart-define=MEATSHOP_ENV=development --dart-define=MEATSHOP_API_URL=http://10.0.2.2:3001
```

Para desktop/iOS Simulator local, use `http://localhost:3001`. Dispositivo físico deve usar o IP local da máquina. Homologação e produção rejeitam URLs sem HTTPS.

Flags disponíveis, ambas desativadas por padrão:

```text
FEATURE_BACKEND_AUTH
FEATURE_BACKEND_MARKETPLACE
```

As flags controlam somente o corte gradual. Elas não podem duplicar regra de negócio ou autorização do backend.

## Sessão e segurança

- access e refresh tokens são armazenados via `flutter_secure_storage`;
- o Flutter 3.35.5 usado no projeto define Android mínimo API 24, atendendo ao requisito mínimo API 23 do armazenamento seguro, e o backup do aplicativo está desativado;
- duas ou mais respostas `401` simultâneas aguardam a mesma renovação;
- a requisição original é repetida no máximo uma vez;
- `403` nunca dispara refresh;
- refresh rejeitado limpa a sessão; erro temporário de rede preserva o refresh token;
- tokens não são incluídos em mensagens de erro ou logs.

O endpoint de troca do Firebase ID Token será implementado na Fase 2. Até lá, as flags permanecem desligadas e os fluxos atuais continuam funcionando.

## Cancelamento e ciclo de vida

Pesquisas e carregamentos de tela devem criar um `CancellationToken` e chamar `cancel()` no `dispose` ou antes de iniciar uma busca substituta. O transporte usa `AbortableRequest`, interrompendo a requisição em vez de apenas ignorar sua resposta.

`ApiFoundation.dispose()` fecha o cliente HTTP quando o escopo da aplicação for encerrado.

## Paginação e erros

`Page<T>` normaliza o contrato `{ data, meta }`. A inconsistência legada `totalPages` é aceita somente na borda; o restante do aplicativo usa `totalPages` tipado.

`ApiFailure` distingue rede, timeout, cancelamento, autenticação, autorização, inexistência, conflito, validação, rate limit, servidor e resposta malformada. Respostas NestJS legadas e o contrato alvo são convertidos para o mesmo tipo.

## Verificação

```powershell
flutter test
flutter analyze --no-pub
```

Casos automatizados da fase:

- `GET /health` público;
- `GET /users/me` com Bearer token;
- sessão ausente sem chamada de rede;
- duas respostas `401` com apenas um refresh;
- limpeza após refresh definitivamente inválido;
- preservação do token em falha de rede;
- timeout e cancelamento distintos;
- normalização de erro e `Retry-After`;
- armazenamento completo ou descarte de sessão parcial;
- paginação nos formatos alvo e temporariamente legado;
- proibição de detalhes de infraestrutura em UI e Providers.

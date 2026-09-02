# Fase 2 — Federação do Firebase Authentication

## Arquitetura implementada

O Firebase continua autenticando e-mail/senha, Google e Apple. O aplicativo envia o Firebase ID Token para `POST /auth/firebase/exchange`; o backend valida assinatura, expiração e revogação com Firebase Admin e emite os access e refresh tokens MeatShop.

PostgreSQL é a fonte da verdade para o vínculo de identidade, perfil, papel, conclusão cadastral, bloqueio e estado da conta. O novo fluxo não lê nem grava perfil ou papel no Firestore.

## Contrato de troca

```http
POST /auth/firebase/exchange
Authorization: Bearer <firebase-id-token>
Content-Type: application/json

{}
```

Resposta:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "user": {
    "id": 1,
    "name": null,
    "email": "cliente@example.com",
    "app_profile": null,
    "phone": null,
    "profile_complete": false
  }
}
```

Quando o e-mail Firebase verificado já pertence a uma conta local ainda não vinculada, o backend retorna `409 ACCOUNT_LINK_REQUIRED`. O aplicativo solicita a senha atual uma única vez e repete a troca com `{ "password": "..." }`. A senha nunca é persistida ou registrada em logs.

Tokens sem e-mail verificado, inválidos, expirados ou revogados são rejeitados. Contas desativadas ou bloqueadas não recebem sessão.

## Perfil incompleto

Uma identidade Firebase nova cria somente o registro mínimo no PostgreSQL. CPF, telefone e `app_profile` permanecem nulos; não são usados valores fictícios. A conclusão usa `PATCH /users/me` com `name`, `cpf`, `phone` e `app_profile`.

Endereço e veículo permanecem temporariamente nos fluxos legados até as fases 4 e 6. Isso não cria escrita dupla de perfil, papel ou identidade.

## Corte gradual

O fluxo é ativado somente com:

```text
FEATURE_BACKEND_AUTH=true
MEATSHOP_ENV=development
MEATSHOP_API_URL=http://10.0.2.2:3001
```

Com a flag desligada, o fluxo Firebase/Firestore anterior permanece disponível. Com a flag ligada, login, restauração, conclusão de perfil e logout usam a sessão MeatShop.

## Configuração do backend

`FIREBASE_SERVICE_ACCOUNT` deve conter o JSON da service account como variável de ambiente. Firebase Admin é inicializado uma única vez e compartilhado com autenticação e FCM.

Execute a migration `1788280000000-AddFirebaseIdentityToUsers` antes de ativar a flag.

## Verificação automatizada

- backend: criação de perfil incompleto, exigência e validação de senha no vínculo e rejeição de e-mail não verificado;
- mobile: header Firebase, corpo de vínculo, parsing do contexto e persistência da sessão MeatShop;
- regressão: testes existentes da fundação HTTP, sessão e fronteiras arquiteturais.

Em 1 de setembro de 2026, as 11 suítes unitárias do backend passaram (35 testes), assim como `typecheck`, build e lint dos arquivos alterados. No mobile, os 23 testes passaram, o analyzer dos arquivos da fase ficou limpo e os builds Web e APK debug com `FEATURE_BACKEND_AUTH=true` foram gerados.

A conclusão formal permanece pendente de duas dívidas anteriores à fase: o analyzer global do mobile ainda reporta 298 ocorrências legadas, e os testes E2E globais do backend exigem uma `.env.test` e o driver SQLite que não existem no repositório. Nenhuma credencial, segredo ou dependência alheia à fase foi inventada para contornar esses gates.

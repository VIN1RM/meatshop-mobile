# Padrões dos contratos mobile

Este documento define o contrato alvo. Inconsistências atuais do backend devem ser corrigidas ou adaptadas explicitamente no repositório remoto; não devem vazar para UI e Providers.

## Transporte

- HTTPS obrigatório fora do ambiente local.
- REST para comandos, consultas, histórico e reconciliação.
- Socket.IO para eventos em tempo real.
- FCM para avisos quando o aplicativo estiver em segundo plano ou encerrado.
- Abrir uma notificação sempre provoca nova consulta à API.

## Configuração

A URL será injetada em build por `--dart-define=MEATSHOP_API_URL=...`. Não serão commitados hosts, tokens ou segredos de produção.

| Ambiente | API esperada |
|---|---|
| Android Emulator | `http://10.0.2.2:3001` |
| iOS Simulator/Desktop | `http://localhost:3001` |
| Dispositivo físico local | `http://<IP-da-maquina>:3001` |
| Homologação | URL HTTPS de homologação |
| Produção | URL HTTPS de produção |

## Autenticação

1. Firebase Auth autentica o usuário.
2. O aplicativo envia `Authorization: Bearer <firebase-id-token>` para `POST /auth/firebase/exchange`.
3. O backend verifica o token e devolve `access_token`, `refresh_token` e o contexto do usuário.
4. REST usa `Authorization: Bearer <access-token>`.
5. Socket.IO envia o mesmo access token em `handshake.auth.token`.
6. Apenas uma renovação pode estar em andamento; as demais requisições aguardam seu resultado.
7. Falha definitiva de refresh limpa a sessão local e volta ao login.

## Tipos

- IDs de domínio: `int` no Dart e `number` inteiro no JSON.
- Firebase UID: `String`, somente no contexto de identidade.
- Datas: ISO-8601 em UTC no transporte; conversão para horário local apenas na apresentação.
- Dinheiro: número JSON convertido a `double` na borda e nunca comparado por igualdade binária em regra financeira.
- Coordenadas: `double`, com latitude entre -90 e 90 e longitude entre -180 e 180.
- Enums: valores em `UPPER_SNAKE_CASE`, desconhecidos tratados como erro de contrato observável.
- Campos opcionais devem distinguir ausência de `null` quando a operação de atualização precisar dessa semântica.

## Paginação

Contrato alvo:

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 0,
    "total_pages": 1
  }
}
```

O backend atualmente usa `totalPages` em parte do catálogo. A Fase 3 deverá padronizar o backend ou encapsular essa diferença no DTO remoto. UI e domínio não podem depender dessa inconsistência.

## Erros

Contrato alvo:

```json
{
  "status_code": 422,
  "code": "INSUFFICIENT_STOCK",
  "message": "Estoque insuficiente para concluir o pedido.",
  "details": [],
  "request_id": "correlation-id"
}
```

Regras:

- `code` é estável e guia comportamento; `message` é texto para apresentação ou fallback.
- erros de validação podem trazer vários itens em `details`;
- nenhuma resposta expõe stack trace, query, segredo ou dado sensível;
- `401` tenta refresh uma vez; `403` não tenta refresh; `409` representa conflito de estado; `422` representa regra/entrada inválida; `429` respeita `Retry-After`;
- falha de rede, timeout, cancelamento, autenticação e erro de domínio serão tipos diferentes no Dart.

Enquanto o backend retornar o formato padrão do NestJS (`statusCode`, `message`, `error`), o cliente da Fase 1 deverá normalizá-lo para a abstração acima.

## Idempotência e concorrência

- checkout, criação de pagamento, aceite de entrega e comandos repetíveis por falha de rede precisam de idempotência no backend;
- o aplicativo nunca assume sucesso sem resposta ou reconciliação posterior;
- preço, cupom, taxa e estoque são recalculados no servidor;
- webhook do provedor é a confirmação oficial do pagamento;
- eventos Socket.IO são sinais para atualizar estado, não substitutos da persistência REST.

## Cancelamento e ciclo de vida

- pesquisas e carregamentos vinculados a telas devem ser canceláveis;
- listeners, streams, timers, posição e sockets devem ser encerrados no `dispose`/logout;
- localização só é coletada com consentimento e durante entrega ativa;
- operações em segundo plano devem obedecer às restrições de Android e iOS.

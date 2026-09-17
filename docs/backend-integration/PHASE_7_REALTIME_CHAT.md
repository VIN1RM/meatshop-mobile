# Fase 7 — Chat e atualizações em tempo real

## Objetivo

Usar o PostgreSQL como histórico oficial e Socket.IO como transporte de eventos para chat e acompanhamento de entrega. O aplicativo sempre reconcilia via REST ao abrir uma tela ou recuperar uma conexão.

## Ativação

```bash
flutter run \
  --dart-define=MEATSHOP_API_URL=http://10.0.2.2:3001 \
  --dart-define=MEATSHOP_ENV=development \
  --dart-define=FEATURE_BACKEND_AUTH=true \
  --dart-define=FEATURE_BACKEND_CHECKOUT=true \
  --dart-define=FEATURE_BACKEND_DELIVERY=true \
  --dart-define=FEATURE_BACKEND_REALTIME=true
```

## Contratos

- `GET /chats` e `GET /chats/unread-count`: caixa de entrada autorizada;
- `GET/POST /orders/:orderId/chat`: histórico e envio;
- `PATCH /orders/:orderId/chat/read`: leitura;
- namespace `/chat`: `chat:join`, `chat:leave`, `chat:typing`, `chat:message` e `chat:read`;
- namespace `/delivery`: `delivery:subscribe-order`, `delivery:location.updated` e `delivery:status.updated`;
- `GET /delivery/orders/:orderId/tracking`: reconciliação da última posição autorizada.

Os três canais são `UNIT` (cliente/unidade), `DELIVERY_PERSON` (cliente/entregador) e `UNIT_DELIVERY_PERSON` (unidade/entregador). Canal e pedido fazem parte da identidade da conversa.

## Segurança e resiliência

- sockets aceitam somente access token MeatShop no campo `auth` ou cookie HTTP-only do painel;
- usuários inativos são desconectados;
- o backend revalida a participação antes de entrar em cada sala;
- clientes não recebem localização de pedidos de terceiros;
- eventos de digitação e envio têm limitação básica de frequência;
- reconexão renova a sessão quando necessário, restaura assinaturas e consulta REST;
- mensagens são deduplicadas pelo ID persistido;
- pedidos entregues ou cancelados mantêm leitura do histórico e bloqueiam novos envios;
- com `FEATURE_BACKEND_REALTIME=true`, o mobile não usa Firestore para chat ou atualizações de tracking.

## Testes

Os testes de contrato cobrem caixa de entrada, histórico, envio, leitura, autoria e canais. No backend, autorização de canais, interlocutores, não lidas e separação entre autônomo/vinculado são cobertos por testes unitários.

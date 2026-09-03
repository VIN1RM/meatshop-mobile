# Fase 6 — Fluxo completo do entregador

## Objetivo

Migrar cadastro, aprovação, operação de entrega, veículos, disponibilidade, histórico e gestão financeira do entregador para o NestJS/PostgreSQL. O Firestore permanece disponível apenas no fluxo legado quando `FEATURE_BACKEND_DELIVERY=false`.

## Ativação gradual

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=APP_ENV=development \
  --dart-define=FEATURE_BACKEND_AUTH=true \
  --dart-define=FEATURE_BACKEND_DELIVERY=true
```

A flag é desativada por padrão. Quando ativa, cadastro de entregador e veículo, perfil, disponibilidade, veículos, ofertas, aceite/rejeição, entrega ativa, código de retirada, confirmação pelo código do cliente, histórico, avaliações, ganhos e metas usam somente a API.

## Contratos implementados

- `POST /delivery/register` — cria o perfil pendente no PostgreSQL;
- `GET /delivery/me` — perfil, aprovação, nota, disponibilidade e veículos;
- `PATCH /delivery/me/availability` — online/offline; exige aprovação e veículo ativo para ficar online;
- `GET /delivery/me/vehicles`, `POST /delivery/vehicles`, `PATCH/DELETE /delivery/me/vehicles/:id` e `PATCH /delivery/vehicles/:id/activate`;
- `GET /delivery/me/orders/available|active|history`;
- `POST /delivery/orders/:orderId/accept|reject`;
- `POST /delivery/units/:unitId/orders/:orderId/verify-pickup` — unidade valida o código apresentado pelo entregador;
- `POST /delivery/orders/:orderId/finish` — entregador informa o código de seis dígitos do cliente;
- `POST /delivery/orders/:orderId/location` e `GET /delivery/orders/:orderId/tracking`;
- `GET /delivery/me/earnings` e `GET/PATCH /delivery/me/goals/:period`;
- `GET /delivery-persons/:deliveryPersonId/reviews`.

## Regras de domínio e segurança

- somente entregador aprovado, online e com veículo ativo aceita uma oferta;
- ofertas são limitadas às unidades às quais o usuário possui vínculo ativo;
- uma rejeição oculta somente aquela oferta para aquele entregador e não altera o pedido;
- o aceite continua atômico e impede dois entregadores de assumirem o mesmo pedido;
- a oferta não expõe endereço exato ou coordenadas do cliente antes do aceite;
- veículo excluído é desativado logicamente; o veículo ativo não pode ser excluído;
- ganhos são derivados de pedidos entregues no PostgreSQL, sem lançamento duplicado;
- localização só é aceita durante entrega atribuída, com entregador online, intervalo mínimo de cinco segundos, precisão opcional e retenção operacional de 30 dias;
- códigos nunca são registrados em logs. O código de retirada é devolvido apenas no aceite autenticado e o código do cliente é validado por hash.

## Migration

`1788540000000-CompleteDeliveryPersonFlow` adiciona disponibilidade, desativação lógica de veículos, rejeições por oferta, metas, precisão e índice temporal de tracking.

## Testes

- backend: disponibilidade exige aprovação e veículo ativo;
- mobile: listagem de ofertas autenticada, disponibilidade e rejeição usam exclusivamente REST;
- a suíte arquitetural continua impedindo novos imports de Firestore.

## Privacidade da localização

A coleta contínua de GPS no Flutter não é ativada automaticamente. Ela exige consentimento explícito e específico do entregador no início de cada entrega, para ao concluir/sair e não opera sem entrega ativa. A transmissão usa deslocamento mínimo de 20 metros; o backend também limita a frequência a cinco segundos, registra precisão e remove pontos com mais de 30 dias.

# Fase 5 — Checkout, pedidos e pagamentos

## Resultado

A Fase 5 conecta o checkout do cliente ao backend NestJS e ao PostgreSQL sob a flag `FEATURE_BACKEND_CHECKOUT`. O backend passa a ser a autoridade para preço, cupom, frete, estoque, pedidos e estado do pagamento. Não existe escrita paralela de pedido ou pagamento no Firestore quando a flag está ativa.

Um carrinho pode conter itens de várias unidades. `POST /orders` cria um pedido por unidade, todos ligados pelo mesmo `checkout_id`, dentro de uma única transação. Se qualquer grupo falhar, nenhum pedido é persistido, o estoque não é parcialmente alterado e o carrinho não é limpo.

## Ativação local

```bash
flutter run \
  --dart-define=MEATSHOP_API_URL=http://10.0.2.2:3001 \
  --dart-define=MEATSHOP_ENV=development \
  --dart-define=FEATURE_BACKEND_AUTH=true \
  --dart-define=FEATURE_BACKEND_MARKETPLACE=true \
  --dart-define=FEATURE_BACKEND_PROFILE_CART=true \
  --dart-define=FEATURE_BACKEND_CHECKOUT=true
```

No Flutter Web, use `http://localhost:3001` como `MEATSHOP_API_URL`.

## Contratos implementados

| Jornada | Contrato |
|---|---|
| Cotação autoritativa | `POST /cart/quote` |
| Criar checkout multiunidade | `POST /orders` + `Idempotency-Key` UUID v4 |
| Histórico e detalhe | `GET /orders` e `GET /orders/:id` |
| Cancelar e restaurar estoque | `PATCH /orders/:id/cancel` |
| Agendar | `PATCH /orders/:id/schedule` |
| Repetir pedido | `POST /orders/:id/repeat` |
| Checkout único no Mercado Pago | `POST /mercadopago/checkouts/:checkoutId/checkout` |
| Confirmar pagamento | `POST /webhooks/mercadopago` |
| Métodos tokenizados | `/saved-payment-methods` |

## Regras de consistência

- O cliente envia somente intenção, endereço, entrega/agendamento, meio de pagamento e cupons por unidade.
- Produto, atividade da categoria, quantidade, preço, desconto, frete e estoque são recalculados no servidor.
- O frete usa as coordenadas geocodificadas da unidade e do endereço. Se elas não estiverem disponíveis, aplica `DEFAULT_DELIVERY_FEE`; retirada tem frete zero.
- Quantidades permitem até três casas decimais e o estoque é bloqueado e alterado deterministicamente dentro da transação PostgreSQL.
- Um cupom sem unidade só é aceito em checkout de unidade única. Carrinho multiunidade usa `coupon_codes: [{ unit_id, code }]`.
- A mesma `Idempotency-Key` devolve o checkout já criado e não duplica pedido, baixa de estoque ou notificação.
- O cancelamento bloqueia o pedido, restaura estoque e libera uso de cupom na mesma transação.

## Pagamento e segurança

- Há uma preferência Mercado Pago por `checkout_id`, cobrindo a soma exata dos pedidos do lote.
- O webhook valida assinatura e janela temporal, consulta o evento no Mercado Pago, confere moeda e valor e atualiza pedidos/pagamentos em transação.
- Eventos repetidos são idempotentes e um pagamento já aprovado não regride por evento pendente ou rejeitado.
- O aplicativo e o banco armazenam somente token/identificador do provedor e metadados seguros como bandeira e últimos quatro dígitos. Número completo e CVV não são persistidos.
- O código de entrega permanece com hash para verificação e cópia criptografada AES-256-GCM para exibição exclusiva ao cliente proprietário até a confirmação.
- A homologação financeira real exige credenciais sandbox válidas em `MP_ACCESS_TOKEN` e `MP_WEBHOOK_SECRET`; segredos não pertencem ao repositório.

## Validação reproduzível

### Automatizada

```bash
# backend
npm test -- --runInBand
npm run build

# mobile
flutter analyze
flutter test
flutter build apk --debug --dart-define=FEATURE_BACKEND_CHECKOUT=true
```

Os testes específicos cobrem agrupamento multiunidade, quantidade fracionada, cupons, frete por distância/fallback, código protegido, header idempotente, checkout agregado e metadados seguros de cartão.

### Manual

1. Autentique um cliente e adicione itens de duas unidades ao mesmo carrinho.
2. Abra a revisão e confirme que a cotação exibe dois grupos calculados pelo servidor.
3. Finalize e confirme dois pedidos com o mesmo checkout no histórico mobile e no painel web.
4. Reenvie a mesma requisição com a mesma chave e confirme que nenhum pedido ou débito de estoque foi duplicado.
5. Cancele os pedidos elegíveis e confirme restauração do estoque.
6. Com credenciais sandbox, abra o checkout Mercado Pago, conclua o pagamento e confirme a transição apenas após o webhook assinado.

## Corte gradual

Com `FEATURE_BACKEND_CHECKOUT=false`, o fluxo legado continua disponível apenas para rollback durante a refatoração. Com a flag ativa, `OrderProvider` e `PaymentProvider` usam exclusivamente os repositórios HTTP e não inicializam os serviços Firestore desses domínios.

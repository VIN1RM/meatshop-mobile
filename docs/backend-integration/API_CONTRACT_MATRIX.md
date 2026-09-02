# Matriz de contratos mobile → backend

## Legenda

- **Pronto**: rota existe e cobre o núcleo da operação; DTOs ainda serão adaptados no Flutter.
- **Parcial**: há estrutura no backend, mas falta operação, autorização, retorno ou filtro necessário.
- **Novo**: contrato proposto para fechar uma lacuna.
- **Externo**: integração não pertence ao backend principal, mas deve ser isolada por interface.

Os nomes de rotas marcados como **Novo** são decisões de contrato da Fase 0 e podem ser implementados nas fases indicadas sem rediscutir o objetivo funcional.

## Rastreabilidade de apresentação

Os repositórios abaixo são contratos alvo. As implementações iniciais usarão API; nenhum deles deverá expor `DocumentSnapshot`, `Timestamp`, cliente HTTP ou token para Provider/UI.

| Tela/fluxo principal | Estado atual | Repositório alvo | Contratos principais |
|---|---|---|---|
| Splash, login e cadastro | `AuthProvider`/`AuthService` | `AuthRepository` | Firebase Auth, `/auth/firebase/exchange`, `/auth/refresh`, `/users/me` |
| Seleção/troca de modo | `AuthProvider` + perfil Firestore | `SessionRepository` | sessão/contexto de `/users/me` |
| Home | `UnitProvider`, `PromotionProvider`, `UserProvider` | `UnitRepository`, `PromotionRepository`, `UserRepository` | `/units`, `/promotions`, `/users/me` |
| Lista de açougues | `UnitProvider`/`UnitService` | `UnitRepository` | `/units` |
| Detalhe do açougue | `ButcherProvider` e serviços de produto/promoção/horário/review | repositórios por domínio | `/units/:id`, `/products`, `/promotions`, business hours, `/reviews` |
| Cortes/categorias | `ProductProvider`/`ProductService` | `CatalogRepository` | `/categories`, `/products` |
| Detalhe do produto | `CartProvider`, `ReviewService` | `CartRepository`, `ReviewRepository` | `/products/:id`, `/cart/items`, `/reviews` |
| Busca | `SearchProvider`/`SearchService` | `SearchRepository` | `/search` |
| Carrinho/bag | `CartProvider`/`CartService` | `CartRepository` | `/cart` e `/cart/items` |
| Endereço e agenda | `AddressProvider`, geocoding direto | `AddressRepository`, `GeocodingRepository` | `/addresses`, `/geocoding`, business hours |
| Revisão do pedido | Providers de carrinho/pagamento/endereço/pedido | `CheckoutRepository` | `/cart/quote`, `/orders` |
| Pagamento | `PaymentProvider`/`PaymentService` | `PaymentRepository` | `/saved-payment-methods`, `/mercadopago/orders/:id/checkout` |
| Pedidos | `OrderService` direto | `OrderRepository` | `/orders`, `/orders/:id` |
| Tracking do cliente | `OrderService`, `ChatService` | `OrderRepository`, `TrackingRepository` | tracking REST + room Socket.IO do pedido |
| Avaliar pedido/produto | `ReviewProvider`, `ProductReviewProvider` | `ReviewRepository` | `/orders/:id/reviews/...` |
| Conta/editar perfil | `UserProvider`/`UserService` | `UserRepository` | `/users/me`, avatar |
| Endereços salvos | `AddressProvider`/`AddressService` | `AddressRepository` | `/addresses` |
| Pagamentos salvos | `PaymentProvider`/`PaymentService` | `PaymentRepository` | `/saved-payment-methods` |
| Lista/chat | `ChatProvider`/`ChatService` | `ChatRepository` | `/chats`, chat por pedido, namespace `/chat` |
| Shell do entregador | `DeliveryProvider`, `UserProvider`, `VehicleProvider` | `DeliveryRepository`, `UserRepository` | `/delivery/me`, active/available orders, vehicles |
| Ofertas de entrega | `DeliveryProvider`/`DeliveryOrderService` | `DeliveryRepository` | `/delivery/orders/available`, accept/reject |
| Entrega ativa | `DeliveryProvider` | `DeliveryRepository`, `TrackingRepository` | active order, status, location, finish |
| Histórico do entregador | `DeliveryProvider` | `DeliveryRepository` | `/delivery/orders/history` |
| Veículo | `VehicleProvider` + Firebase direto | `VehicleRepository` | `/delivery/vehicles` e upload |
| Ganhos/relatórios/metas | `DeliveryEarningsProvider`/Firestore | `DeliveryEarningsRepository` | `/delivery/me/earnings`, `/delivery/me/goals` |
| Notificações | `NotificationProvider`/`NotificationService` | `NotificationRepository`, `PushService` | `/notifications`, device tokens, FCM |
| Preferências | `UserPreferencesProvider`/SharedPreferences | `PreferencesRepository` local | sem endpoint quando for apenas preferência do dispositivo |
| Assistente de receitas | `RecipeProvider`/`RecipeService` | `RecipeAssistantRepository` | API externa configurável |

## Identidade e sessão

| Jornada/tela | Estado atual mobile | Contrato alvo | Situação | Fase |
|---|---|---|---|---|
| Login e-mail/senha | `AuthProvider` → Firebase Auth/Firestore | Firebase Auth + `POST /auth/firebase/exchange` | **Novo** | 2 |
| Login Google/Apple | Firebase Auth + criação de perfil Firestore | Firebase Auth + exchange | **Novo** | 2 |
| Cadastro cliente | Firebase Auth + documentos e índices únicos | exchange + conclusão segura de `users/me` | **Parcial** | 2 |
| Cadastro entregador | Firebase Auth + `delivery_persons`/vehicle no Firestore | exchange + `POST /delivery/register` + veículos | **Parcial** | 2/6 |
| Perfil BOTH/troca de modo | `app_profile` no Firestore | `app_profile` no PostgreSQL retornado pela sessão | **Parcial** | 2 |
| Restaurar sessão | Firebase current user + Firestore | exchange/refresh + `GET /users/me` | **Parcial** | 2 |
| Refresh | inexistente para sessão MeatShop | `POST /auth/refresh` | **Pronto** | 1/2 |
| Logout | Firebase sign-out | `POST /auth/logout`, remover device token e Firebase sign-out | **Parcial** | 2/8 |
| Recuperar/trocar senha | Firebase Auth direto | Firebase Auth para identidade Firebase; backend coordena conta/vínculo | **Parcial** | 2 |
| Excluir conta | Firebase + Firestore pelo cliente | `DELETE /users/me` coordenando PostgreSQL e Firebase Admin | **Novo** | 2/10 |
| Bloqueio de login | coleção `login_attempts` | política central do backend associada à identidade | **Parcial** | 2/10 |

### Contrato novo: troca de identidade

`POST /auth/firebase/exchange`

Entrada: Firebase ID Token no header `Authorization`. Se um e-mail verificado coincidir com uma conta local ainda não vinculada, o backend responde `ACCOUNT_LINK_REQUIRED`; a repetição inclui a senha atual somente para confirmar o primeiro vínculo.

Saída:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "user": {
    "id": 1,
    "name": "Cliente",
    "email": "cliente@example.com",
    "app_profile": "CLIENT",
    "profile_complete": true
  }
}
```

O backend deve informar um estado explícito de perfil incompleto; não deve criar CPF, telefone ou papel com valores fictícios.

## Perfil, endereços e mídia

| Jornada/tela | Contrato alvo | Situação | Observação |
|---|---|---|---|
| Exibir perfil | `GET /users/me` | **Pronto** | Adaptar IDs e resposta |
| Editar perfil | `PATCH /users/me` | **Pronto** | Backend valida unicidade |
| Avatar | `POST /users/me/avatar` e `DELETE /users/me/avatar` | **Novo** | Substitui Base64 e rota administrativa `users/:id/logo` |
| Listar endereços | `GET /addresses` | **Pronto** | Usuário derivado do token |
| Detalhar endereço | `GET /addresses/:id` | **Pronto** | Autorização existente |
| Criar endereço | `POST /addresses` | **Pronto** | Coordenadas devem ser validadas |
| Editar endereço | `PATCH /addresses/:id` | **Pronto** | — |
| Tornar padrão | `PATCH /addresses/:id/default` | **Pronto** | Operação atômica no backend |
| Excluir endereço | `DELETE /addresses/:id` | **Pronto** | Definir regra para endereço usado em pedido |
| Consultar CEP cliente | `GET /geocoding/cep/:cep` | **Novo** | Hoje há apenas lookup administrativo da unidade |
| Geocodificar endereço | `POST /geocoding/resolve` | **Novo** | Retorna coordenadas e precisão/fonte |

## Marketplace

| Jornada/tela | Contrato alvo | Situação | Lacuna |
|---|---|---|---|
| Listar açougues | `GET /units?page=&limit=&lat=&lng=&radius_km=` | **Novo** | Backend só lista unidades geridas |
| Detalhar açougue | `GET /units/:id` | **Novo** | `settings` é administrativo |
| Horários | `GET /units/:unitId/business-hours` | **Pronto** | Público |
| Listar categorias | `GET /categories?unit_id=` | **Pronto** | Público |
| Detalhar categoria | `GET /categories/:id` | **Pronto** | Público |
| Produtos por unidade/categoria | `GET /products?unit_id=&category_id=&active=true&page=&limit=` | **Pronto** | Deve filtrar disponibilidade vendável para catálogo |
| Detalhar produto | `GET /products/:id` | **Pronto** | Público |
| Promoções ativas | `GET /promotions?unit_id=&active=true&page=&limit=` | **Parcial** | Revisar acesso público, filtros e paginação |
| Busca combinada | `GET /search?q=&unit_id=&category_id=&min_price=&max_price=&page=&limit=` | **Novo** | Hoje o cliente faz múltiplas consultas Firestore |
| Avaliações da unidade/produto | `GET /reviews?...` | **Parcial** | Confirmar filtros públicos e paginação |

## Carrinho e checkout

| Operação | Contrato alvo | Situação | Regra crítica |
|---|---|---|---|
| Consultar carrinho | `GET /cart` | **Pronto** | Retornar snapshots necessários à apresentação |
| Adicionar item | `POST /cart/items` | **Pronto** | Revalidar produto, unidade, atividade e estoque |
| Alterar quantidade | `PATCH /cart/items/:itemId` | **Pronto** | Quantidade positiva e estoque |
| Remover item | `DELETE /cart/items/:itemId` | **Pronto** | — |
| Limpar carrinho | `DELETE /cart` | **Pronto** | — |
| Calcular prévia | `POST /cart/quote` | **Novo** | Preço, cupom, endereço, agenda e taxa calculados pelo servidor |
| Validar cupom | `GET /coupons/validate/:code` | **Pronto** | Deve considerar usuário/unidade/carrinho |
| Métodos salvos | `GET/POST /saved-payment-methods` | **Pronto** | Somente IDs tokenizados e metadados |
| Tornar padrão | `PATCH /saved-payment-methods/:id/default` | **Pronto** | — |
| Remover método | `DELETE /saved-payment-methods/:id` | **Pronto** | Remover/vincular também no provedor quando aplicável |

## Pedidos e pagamentos

| Jornada | Contrato alvo | Situação | Observação |
|---|---|---|---|
| Criar pedido | `POST /orders` | **Pronto** | Backend usa carrinho e valida regras |
| Listar histórico/ativos | `GET /orders` com filtros e paginação | **Parcial** | Hoje retorna lista sem filtros/paginação explícitos |
| Detalhar pedido | `GET /orders/:id` | **Pronto** | Autorização por participante |
| Cancelar | `PATCH /orders/:id/cancel` | **Pronto** | Restaura estoque conforme regra |
| Agendar | `PATCH /orders/:id/schedule` | **Pronto** | Validar horário da unidade |
| Repetir | `POST /orders/:id/repeat` | **Pronto** | Revalidar preço/estoque |
| Checkout Mercado Pago | `POST /mercadopago/orders/:id/checkout` | **Pronto** | Integração ainda precisa homologação ponta a ponta |
| Confirmação de pagamento | `POST /webhooks/mercadopago` | **Pronto** | Webhook/idempotência são autoridade |
| Código do cliente | incluído de forma protegida em detalhe/contexto autorizado | **Parcial** | Nunca enviar código ao ator incorreto ou registrar em log |

## Entregador

| Jornada/tela | Contrato alvo | Situação |
|---|---|---|
| Registrar entregador | `POST /delivery/register` | **Pronto** |
| Meu perfil/status | `GET /delivery/me` | **Novo** |
| Atualizar disponibilidade | `PATCH /delivery/me/availability` | **Novo** |
| Listar veículos | `GET /delivery/vehicles` | **Novo** |
| Criar veículo | `POST /delivery/vehicles` | **Pronto** |
| Editar veículo | `PATCH /delivery/vehicles/:id` | **Novo** |
| Excluir veículo | `DELETE /delivery/vehicles/:id` | **Novo** |
| Ativar veículo | `PATCH /delivery/vehicles/:id/activate` | **Pronto** |
| Fotos/documentos do veículo | endpoint multipart autorizado | **Novo** |
| Entregas disponíveis | `GET /delivery/orders/available?page=&limit=` | **Novo** |
| Entrega ativa | `GET /delivery/orders/active` | **Novo** |
| Histórico | `GET /delivery/orders/history?page=&limit=` | **Novo** |
| Aceitar | `POST /delivery/orders/:orderId/accept` | **Pronto** |
| Rejeitar oferta | `POST /delivery/orders/:orderId/reject` | **Novo** |
| Atualizar status | `PATCH /delivery/orders/:orderId/status` | **Pronto** |
| Atualizar localização | `POST /delivery/orders/:orderId/location` | **Pronto** |
| Finalizar com código | `POST /delivery/orders/:orderId/finish` | **Pronto** |
| Tracking autorizado | `GET /delivery/orders/:orderId/tracking` | **Pronto** |
| Avaliações | `GET /delivery-persons/:id/reviews` | **Pronto** |
| Resumo de ganhos | `GET /delivery/me/earnings?from=&to=` | **Novo** |
| Metas | `GET/PATCH /delivery/me/goals/:period` | **Novo** |

O aceite, códigos, status e localização já possuem núcleo no backend. Disponibilidade, descoberta de ofertas, perfil próprio, CRUD completo de veículo e ganhos são os maiores bloqueadores da jornada do entregador.

## Chat

| Jornada | Contrato alvo | Situação |
|---|---|---|
| Histórico por pedido/canal | `GET /orders/:orderId/chat?participant_type=&before=&limit=` | **Pronto** |
| Enviar por REST | `POST /orders/:orderId/chat` | **Pronto** |
| Marcar leitura | `PATCH /orders/:orderId/chat/read` | **Pronto** |
| Listar conversas | `GET /chats?status=&page=&limit=` | **Novo** |
| Total não lido | incluído na listagem ou `GET /chats/unread-count` | **Novo** |
| Tempo real | namespace `/chat`; `chat:join`, `chat:leave`, `chat:typing`, `chat:send` | **Pronto** |
| Eventos recebidos | `chat:ready`, `chat:joined`, `chat:message`, `chat:read`, `chat:typing`, `chat:error` | **Pronto** |

Os canais existentes são `UNIT`, `DELIVERY_PERSON` e `UNIT_DELIVERY_PERSON`, correspondendo a cliente↔unidade, cliente↔entregador e unidade↔entregador.

## Rastreamento em tempo real

| Consumidor | Contrato alvo | Situação |
|---|---|---|
| Painel da unidade | namespace `/delivery`, `delivery:subscribe` por unidade | **Pronto** |
| Cliente do pedido | `delivery:subscribe-order` com autorização por pedido | **Novo** |
| Entregador do pedido | atualização REST + confirmação/reconciliação | **Parcial** |
| Eventos | `delivery:location.updated`, `delivery:status.updated` | **Parcial** |

O gateway atual autoriza apenas assinatura por unidade com `VIEW_DELIVERIES`. É necessário um room por pedido, autorizado para cliente, entregador atribuído e unidade, para o tracking mobile sem expor localizações de outras entregas.

## Notificações

| Jornada | Contrato alvo | Situação |
|---|---|---|
| Listar | `GET /notifications?page=&limit=&read=` | **Pronto** |
| Marcar uma | `PATCH /notifications/:id/read` | **Pronto** |
| Marcar todas | `PATCH /notifications/read-all` | **Pronto** |
| Registrar token | `POST /notifications/device-tokens` | **Pronto** |
| Remover token | `DELETE /notifications/device-tokens` | **Pronto** |
| Foreground realtime | namespace `/notifications`, evento `notification:new` | **Pronto** |
| Background/encerrado | FCM enviado pelo backend | **Parcial** | Exige Firebase Admin configurado e payloads testados |

## Recursos complementares

| Recurso | Decisão |
|---|---|
| Assistente de receitas | Continuará serviço HTTP externo, mas atrás de contrato/repositório próprio e configuração por ambiente |
| ViaCEP/geocoding | Preferir backend para normalização, cache, observabilidade e troca de provedor |
| Exportação de ganhos | Gerada a partir de dados retornados pelo backend; não consulta Firestore |
| Preferências de notificação/UI | Preferências locais quando só afetam o dispositivo; consentimentos e finalidade relevantes também no backend |
| Suporte | Backend possui módulo, mas não há jornada mobile consolidada; fica fora do corte inicial até definição de produto |

## Sequência de dependências do backend

1. Exchange Firebase e contexto do usuário.
2. Unidades públicas, busca e geocodificação.
3. Quote do carrinho e ajustes de listagem de pedidos.
4. Perfil/disponibilidade/veículos/ofertas/ganhos do entregador.
5. Listagem de conversas e room de tracking por pedido.
6. Padronização transversal de erros, paginação e idempotência.

Essa sequência permite que o mobile migre por domínio sem escrita dupla e sem esperar que todas as lacunas sejam implementadas ao mesmo tempo.

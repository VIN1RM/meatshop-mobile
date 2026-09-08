# Linha de base Firebase

## Resumo

Na linha de base existem:

- 47 arquivos Dart importando `cloud_firestore`;
- 15 arquivos Dart importando `firebase_auth`;
- 1 arquivo Dart importando `firebase_storage`;
- Firebase Messaging inicializado para push;
- modelos, Providers, serviços e algumas telas acoplados diretamente a tipos do Firestore;
- um seed Firestore que replica grande parte do domínio PostgreSQL;
- nenhuma regra de Firestore ou Storage versionada neste repositório.

Não encontrar regras versionadas não prova que o projeto Firebase publicado esteja sem regras. Significa que elas não são auditáveis, reproduzíveis nem revisáveis a partir deste repositório.

## Propriedade final

| Capacidade | Situação atual | Destino |
|---|---|---|
| Login e-mail/senha | Firebase Auth | Manter Firebase Auth |
| Google e Apple | Firebase Auth | Manter Firebase Auth |
| Perfil, CPF, telefone e papel | Firestore | PostgreSQL via NestJS |
| Tentativas e bloqueio de login | Firestore e Firebase | Backend/PostgreSQL; Firebase apenas autentica |
| Endereços | Firestore | PostgreSQL via `/addresses` |
| Unidades e horários | Firestore | PostgreSQL via API pública |
| Produtos, categorias e estoque | Firestore | PostgreSQL via API pública |
| Carrinho | Firestore | PostgreSQL via `/cart` |
| Pedidos e histórico | Firestore | PostgreSQL via `/orders` |
| Métodos de pagamento | Firestore | PostgreSQL com referências tokenizadas do Mercado Pago |
| Promoções e cupons | Firestore | PostgreSQL via API |
| Entregadores e veículos | Firestore | PostgreSQL via módulo Delivery |
| Localização e tracking | Firestore | PostgreSQL + Socket.IO do backend |
| Chat | Firestore | PostgreSQL + REST/Socket.IO do backend |
| Avaliações | Firestore | PostgreSQL via módulo Reviews |
| Notificações persistidas | Firestore | PostgreSQL via módulo Notifications |
| Transporte de push | FCM | Manter FCM, acionado pelo backend |
| Token do dispositivo | Campo Firestore do usuário | PostgreSQL via `/notifications/device-tokens` |
| Imagens em Base64 | Firestore | Upload controlado + URL/metadados no PostgreSQL |
| Firebase Storage | Uso parcial em veículo | Reavaliar; não será fonte de autorização ou metadados |
| Preferências visuais | SharedPreferences | Manter local |

## Coleções operacionais legadas

O catálogo central declara as coleções `users`, `units`, `products`, `orders`, `payments`, `carts`, `promotions`, `coupons`, `notifications`, `chats`, `reviews`, `delivery_reviews`, `delivery_persons`, `support_tickets`, `audit_logs` e `login_attempts`, além de subcoleções de endereços, itens, histórico, tracking, veículos, categorias, horários e métodos de pagamento.

Todas são consideradas legadas para esta refatoração. Nenhuma coleção Firestore será a fonte definitiva de um domínio operacional.

## Acoplamentos que devem desaparecer

1. Modelos de domínio recebem `DocumentSnapshot`, `Timestamp` ou `DocumentReference`.
2. Providers consultam `FirebaseFirestore.instance` diretamente.
3. Telas de carrinho, checkout e receitas consultam documentos.
4. Serviços alteram status de pedido e entrega sem passar pelas regras do backend.
5. Avaliações recalculam médias no cliente.
6. Imagens são serializadas como Data URI/Base64.
7. O Firebase UID é usado como ID de todas as entidades relacionadas.
8. O token FCM é gravado diretamente no documento do usuário.

## Firebase permitido depois do corte

Imports Firebase deverão ficar concentrados em `lib/infra/firebase` ou camada equivalente:

- `firebase_core`;
- `firebase_auth`;
- `firebase_messaging`;
- `firebase_app_check`, quando aprovado e adicionado;
- Crashlytics, Analytics e Performance, quando aprovados e adicionados.

`cloud_firestore` será removido ao final. `firebase_storage` só permanecerá se houver uma decisão explícita de armazenamento de objetos, regras versionadas e metadados validados pelo backend.

## Regra de segurança

Firebase confirma identidade e entrega mensagens; não concede autorização de negócio. Perfil ativo, aprovação de entregador, propriedade de pedido, vínculo com unidade e permissões são sempre validados pelo NestJS com dados do PostgreSQL.

# Integração com o backend MeatShop

Este diretório contém os artefatos de engenharia da refatoração que fará o aplicativo Flutter consumir o backend NestJS e usar o PostgreSQL como fonte única da verdade.

## Estado da integração

Data da linha de base: 1 de setembro de 2026.

Branch de trabalho: `refactor/mobile-with-backend`.

- Fase 0 — contratos, inventário e reset seguro: concluída;
- Fase 1 — fundação da API Flutter: implementada, testada e documentada.
- Fase 2 — federação do Firebase Authentication: implementada, testada e protegida por feature flag.
- Fase 3 — marketplace público PostgreSQL: implementada sob feature flag, com catálogo vendável e busca combinada.
- Fase 4 — perfil, endereços, mídia e carrinho multiunidade: implementada sob feature flag e validada por testes.
- Fase 5 — checkout, pedidos e pagamentos: implementada sob feature flag, com checkout multiunidade transacional e Mercado Pago pronto para homologação sandbox.
- Fase 6 — fluxo do entregador: implementada, testada e protegida por feature flag, com consentimento explícito para localização durante a entrega ativa.

Artefatos:

- [Inventário Firebase](FIREBASE_BASELINE.md): dependências atuais, propriedade dos dados e dívida legada;
- [Matriz de contratos](API_CONTRACT_MATRIX.md): jornada mobile, implementação atual e endpoint alvo;
- [Padrões de API](API_STANDARDS.md): convenções que orientarão os repositórios e contratos;
- [Ambientes e reset](ENVIRONMENTS_AND_RESET.md): configuração local, homologação, produção e descarte seguro de dados;
- [Linha de base de qualidade](QUALITY_BASELINE.md): testes, analyzer, riscos e gates das próximas fases.
- [Fundação da API](PHASE_1_API_FOUNDATION.md): composição, configuração, sessão, erros, cancelamento e uso pelos próximos repositórios.
- [Federação Firebase Auth](PHASE_2_FIREBASE_AUTH_FEDERATION.md): troca de identidade, vínculo seguro, perfil incompleto, sessão e corte gradual.
- [Marketplace público](PHASE_3_MARKETPLACE.md): unidades sempre públicas, catálogo vendável, busca, paginação e corte gradual.
- [Perfil, endereços e carrinho](PHASE_4_PROFILE_ADDRESS_CART.md): upload multipart, CEP, quantidades fracionadas e carrinho multiunidade.
- [Checkout, pedidos e pagamentos](PHASE_5_CHECKOUT_ORDERS_PAYMENTS.md): cotação autoritativa, transação multiunidade, idempotência, Mercado Pago e código protegido.
- [Fluxo completo do entregador](PHASE_6_DELIVERY_FLOW.md): aprovação, veículos, disponibilidade, ofertas, códigos, histórico, avaliações, ganhos, metas e política de localização.

## Decisões registradas

1. O Flutter acessará dados do negócio somente pelo NestJS.
2. O NestJS será o único componente com acesso ao PostgreSQL.
3. O PostgreSQL será a fonte da verdade para usuários, perfis, unidades, catálogo, carrinho, pedidos, pagamentos, entregas, chat, avaliações e notificações persistidas.
4. O Firebase Authentication continuará responsável pela autenticação primária do aplicativo.
5. O backend validará o Firebase ID Token e emitirá a sessão MeatShop usada em REST e Socket.IO.
6. FCM continuará como transporte de push; os registros dos dispositivos pertencerão ao PostgreSQL.
7. App Check, Crashlytics, Analytics e Performance poderão ser utilizados como serviços complementares.
8. Não haverá sincronização bidirecional Firestore/PostgreSQL nem escrita dupla no cliente.
9. Como não existem dados reais, a transição utilizará reset e seed, não migração de legado.
10. IDs de domínio serão os IDs inteiros do PostgreSQL. O Firebase UID existirá apenas como identidade externa do usuário.

## Arquitetura alvo

```text
UI -> Provider -> Repository contract -> Repository implementation -> API client
                                                               |-> REST
                                                               `-> Socket.IO

Firebase Auth -> Firebase ID Token -> POST /auth/firebase/exchange
                                      -> access/refresh token MeatShop

NestJS -> PostgreSQL
NestJS -> Firebase Admin -> FCM
```

As pastas `lib/data` e `lib/infra` são ocupadas progressivamente, sem reescrever telas em massa:

- `lib/data`: contratos de repositório e, nas próximas fases, DTOs e mapeadores remotos;
- `lib/infra`: cliente HTTP, implementações de repositório, sessão segura e integrações permitidas;
- `lib/models`: modelos de domínio sem imports de infraestrutura;
- `lib/providers`: estado e orquestração de casos de uso, sem Firestore ou HTTP direto;
- `lib/ui`: apresentação, sem acesso a banco, Firebase operacional ou transporte.

## Regra de evolução

O teste `test/architecture/no_new_cloud_firestore_dependencies_test.dart` registra todos os imports legados de `cloud_firestore` existentes nesta data.

- Um novo import fora da linha de base falha o teste.
- Quando um arquivo for migrado, seu import e sua entrada na linha de base devem ser removidos no mesmo commit.
- Adicionar um arquivo à lista para contornar o teste é proibido; qualquer exceção precisa de decisão arquitetural documentada.

## Critério atendido para iniciar a Fase 2

- fundação central da API disponível por `ApiFoundation`;
- sessão persistida com segurança e refresh concorrente protegido;
- endpoint público e protegido cobertos por contrato e testes;
- cancelamento, timeout, paginação e erros normalizados;
- UI e Providers protegidos de dependências de infraestrutura por teste.

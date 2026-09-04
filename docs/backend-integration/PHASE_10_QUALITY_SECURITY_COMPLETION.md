# Fase 10 — Qualidade, segurança e conclusão

Concluída em 4 de setembro de 2026.

## Resultado arquitetural

- PostgreSQL é a única fonte de verdade para perfil, papéis, permissões e dados operacionais.
- O Flutter não depende de `cloud_firestore` nem de `firebase_storage`; um teste arquitetural impede sua reintrodução.
- Firebase permanece apenas para Authentication, FCM, App Check, Crashlytics, Analytics consentido e Performance.
- UI e Providers dependem de contratos; implementações HTTP/Socket ficam em `lib/infra`.
- Cotação, estoque, promoções, pagamentos, pedidos, avaliações, entregas, chat e notificações são autoritativos no backend.

## Segurança e LGPD

- Tokens, senhas, CPF, telefone e payloads pessoais não são registrados nos novos logs.
- Access token expirado é renovado uma única vez mesmo sob chamadas concorrentes; falha temporária preserva o refresh token.
- Checkout usa `Idempotency-Key`; estoque é revalidado e alterado em transação com bloqueio pessimista.
- Webhook Mercado Pago valida assinatura, janela temporal, consulta oficial, moeda e valor.
- Localização existe apenas durante entrega ativa e possui retenção operacional de 30 dias.
- `DELETE /users/me` revoga sessões/dispositivos, desativa a conta e anonimiza dados pessoais; histórico financeiro/operacional referenciado permanece sem identidade pessoal.
- `GET /delivery/:id/public-profile` somente revela o entregador se ele estiver atribuído a um pedido do cliente autenticado.
- O Firestore continua protegido por regra `deny all`.

## Cobertura automatizada

- Modelos, sessão segura, timeout, cancelamento, offline, refresh concorrente e respostas inválidas.
- Repositórios de autenticação, marketplace, perfil, endereço, carrinho, checkout, pagamentos, entregas, chat, push, receitas e avaliações.
- Providers críticos e fronteiras arquiteturais.
- Backend: vínculo Firebase, autorização, perfil público do entregador, estado de avaliações, anonimização de conta, estoque, preço, códigos, App Check, chat e seed.

## Gates executados

```text
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
flutter build apk --release --dart-define=MEATSHOP_ENV=production --dart-define=MEATSHOP_API_URL=https://api.meatshop.example
npm run typecheck
npm run build
npm run lint
npm test -- --runInBand
npm run test:e2e
npm audit --omit=dev --audit-level=high
```

O analyzer termina sem erros, warnings ou diagnósticos de nível info. Os 47 testes mobile, 77 testes unitários e 3 E2E do backend e 3 testes do painel passam. O APK release usa uma URL HTTPS reservada apenas para validar a composição; a distribuição deve usar a URL real do ambiente.

O build iOS exige macOS/Xcode e deve ser executado no CI macOS com `flutter build ios --release --no-codesign`. Homologações com FCM/APNs, App Check real e Mercado Pago sandbox exigem as credenciais dos respectivos ambientes.

Os lints globais do backend e do painel estão limpos. Os E2E de health, metrics e app usam PostgreSQL real no CI e foram separados dos testes unitários. O CI também constrói a stack Docker, executa as migrations e mede 100 chamadas de health com limite de p95.

## Homologação conjunta

Após preparar o ambiente conforme `SETUP.md`, validar:

1. cliente entra pelo Firebase, consulta catálogo, fecha checkout e acompanha o pedido;
2. unidade visualiza o mesmo pedido/estoque no painel e avança o preparo;
3. entregador fica online, aceita, retira e conclui com os códigos protegidos;
4. os três participantes recebem eventos, conversam somente no canal autorizado e reconciliam após perda de rede;
5. cliente avalia unidade/produtos/entregador uma única vez e pode excluir a conta.

Nenhuma etapa deve criar coleção no Firestore.

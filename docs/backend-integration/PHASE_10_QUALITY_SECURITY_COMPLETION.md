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
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
flutter build apk --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.meatshop.example
npm run typecheck
npm run build
npm test -- --runInBand
```

O analyzer terminou sem erros nem warnings; permanecem 248 diagnósticos de nível `info` herdados (principalmente APIs visuais depreciadas e regras de estilo), que não bloqueiam o artefato. O APK release foi produzido com uma URL HTTPS reservada para validação de composição; a distribuição deve usar a URL real do ambiente.

O build iOS exige macOS/Xcode e deve ser executado no CI macOS com `flutter build ios --release --no-codesign`. Homologações com FCM/APNs, App Check real e Mercado Pago sandbox exigem as credenciais dos respectivos ambientes.

O comando global `npm run lint` possui dívida histórica fora do escopo do corte (centenas de ocorrências já existentes); os arquivos alterados nesta fase são formatados e validados isoladamente. Os E2E legados de health/metrics/app requerem correção do harness SQLite/JWT; os testes unitários e o build NestJS permanecem autoritativos nesta execução.

## Homologação conjunta

Após preparar o ambiente conforme `SETUP.md`, validar:

1. cliente entra pelo Firebase, consulta catálogo, fecha checkout e acompanha o pedido;
2. unidade visualiza o mesmo pedido/estoque no painel e avança o preparo;
3. entregador fica online, aceita, retira e conclui com os códigos protegidos;
4. os três participantes recebem eventos, conversam somente no canal autorizado e reconciliam após perda de rede;
5. cliente avalia unidade/produtos/entregador uma única vez e pode excluir a conta.

Nenhuma etapa deve criar coleção no Firestore.

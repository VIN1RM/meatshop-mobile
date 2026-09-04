# Fase 8 — Push e serviços Firebase complementares

## Resultado

O Firebase permanece como transporte e camada de observabilidade. As notificações e os dispositivos pertencem ao PostgreSQL, e todo toque em push reconsulta a API antes de navegar.

## Ativação mobile

```text
--dart-define=FEATURE_BACKEND_FIREBASE_SERVICES=true
--dart-define=FIREBASE_ANALYTICS_CONSENT=true
--dart-define=FIREBASE_PERFORMANCE_ENABLED=true
```

Analytics inicia desativado sem consentimento explícito. O único evento definido nesta fase é `push_open`, cujo parâmetro `destination` contém apenas a categoria da tela, nunca ID, texto, e-mail, telefone, token ou localização.

## Configuração backend

`FIREBASE_SERVICE_ACCOUNT` configura o Firebase Admin já compartilhado por Auth, FCM e App Check. `FIREBASE_APP_CHECK_ENFORCED=true` exige `X-Firebase-AppCheck` nas requisições identificadas por `X-MeatShop-Client: mobile`; o painel web permanece independente desse atestado.

Ative a imposição somente depois de registrar os aplicativos Android/iOS e os provedores Play Integrity/App Attest no console Firebase. Builds de desenvolvimento usam o provedor debug e exigem o cadastro do token de debug no console.

## Contratos

- `POST /notifications/device-tokens`: registra ou transfere com segurança o token ao usuário autenticado; recebe `fcm_token`, `platform` e `app_version` opcional.
- `DELETE /notifications/device-tokens`: remove o dispositivo no logout, recebendo o token no corpo para que ele não apareça em URLs ou access logs.
- `GET /notifications`: devolve a fonte atual no PostgreSQL para revalidar o toque.
- `PATCH /notifications/:id/read` e `PATCH /notifications/read-all`: atualizam leitura.

Tokens inválidos retornados pelo FCM são excluídos imediatamente. Tokens sem atividade por 90 dias são removidos antes de um novo envio. O refresh do FCM atualiza o registro automaticamente.

## Push e privacidade

Eventos reais de pedido, entrega, chat e suporte persistem a notificação antes do envio. O payload transporta somente `notification_id`, `type` e `action_url`; o texto exibido na tela bloqueada é genérico e não inclui códigos de retirada/entrega, conversa, token ou dado pessoal.

Foreground usa banner interno. Background e aplicativo encerrado usam FCM/notificação local. Ao tocar, o mobile busca novamente `/notifications`, confirma que o registro pertence à sessão e somente então marca como lido e navega.

Crashlytics captura erros Flutter fatais e erros assíncronos sem chaves personalizadas pessoais. Performance Monitoring pode ser desligado por ambiente. Nenhum desses serviços recebe dados operacionais como fonte de verdade.

## Validação

- testes backend para App Check, registro de dispositivo e ciclo da sala de tracking;
- testes Flutter para headers de atestação, registro/remoção FCM, reconsulta de notificação e classificação da falha de autenticação realtime;
- `flutter test`, `flutter analyze`, build Android, testes, typecheck e build NestJS.

O envio real exige credenciais Firebase e dispositivos cadastrados nos consoles Apple/Google; a implementação local é validada por contratos automatizados sem registrar tokens em logs.

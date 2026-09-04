# Setup do MeatShop 3.0.0

## Requisitos

- Node.js e npm compatíveis com o backend NestJS;
- Flutter 3.35.5 / Dart 3.9.2;
- Docker Desktop com PostgreSQL;
- projeto Firebase configurado para Auth, FCM, App Check e observabilidade;
- Android SDK; macOS/Xcode para build iOS.

## Preparação limpa

1. Na raiz web/backend, copie os exemplos de ambiente sem versionar segredos.
2. Suba PostgreSQL com `docker compose up -d`.
3. Em `meatshop-backend`, execute `npm install`, `npm run migration:run`, `npm run build` e `npm run seed:run`.
4. Inicie a API com `npm run start:dev` e confirme `/health` e `/api` (Swagger).
5. No mobile, configure `API_BASE_URL` para o host acessível pelo aparelho/emulador.
6. Execute `flutter pub get` e `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001` no Android Emulator.

Os comandos destrutivos e as contas sintéticas estão em `docs/backend-integration/ENVIRONMENTS_AND_RESET.md` e `PHASE_9_RESET_SEED_FIRESTORE_CUTOVER.md`. Nunca use o reset em produção.

## Validação

```text
flutter test
flutter analyze
flutter build apk --debug
```

No backend:

```text
npm run typecheck
npm run build
npm test -- --runInBand
```

Firebase Auth deve continuar ativo. Firestore deve permanecer vazio e com regras que negam leitura/escrita. Não adicione `cloud_firestore` ou `firebase_storage` ao aplicativo.

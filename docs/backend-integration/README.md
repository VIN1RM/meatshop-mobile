# Integração com o backend MeatShop

Este diretório contém os artefatos de engenharia da refatoração que fará o aplicativo Flutter consumir o backend NestJS e usar o PostgreSQL como fonte única da verdade.

## Estado da Fase 0

Data da linha de base: 1 de setembro de 2026.

Branch de trabalho: `refactor/mobile-with-backend`.

Artefatos:

- [Inventário Firebase](FIREBASE_BASELINE.md): dependências atuais, propriedade dos dados e dívida legada;
- [Matriz de contratos](API_CONTRACT_MATRIX.md): jornada mobile, implementação atual e endpoint alvo;
- [Padrões de API](API_STANDARDS.md): convenções que orientarão os repositórios e contratos;
- [Ambientes e reset](ENVIRONMENTS_AND_RESET.md): configuração local, homologação, produção e descarte seguro de dados;
- [Linha de base de qualidade](QUALITY_BASELINE.md): testes, analyzer, riscos e gates das próximas fases.

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

As pastas `lib/data` e `lib/infra` estão vazias na linha de base. Elas serão ocupadas progressivamente, sem reescrever telas em massa:

- `lib/data`: DTOs remotos, mapeadores e implementações de repositório;
- `lib/infra`: cliente HTTP, sessão segura, Socket.IO e integrações Firebase permitidas;
- `lib/models`: modelos de domínio sem imports de infraestrutura;
- `lib/providers`: estado e orquestração de casos de uso, sem Firestore ou HTTP direto;
- `lib/ui`: apresentação, sem acesso a banco, Firebase operacional ou transporte.

## Regra de evolução

O teste `test/architecture/no_new_cloud_firestore_dependencies_test.dart` registra todos os imports legados de `cloud_firestore` existentes nesta data.

- Um novo import fora da linha de base falha o teste.
- Quando um arquivo for migrado, seu import e sua entrada na linha de base devem ser removidos no mesmo commit.
- Adicionar um arquivo à lista para contornar o teste é proibido; qualquer exceção precisa de decisão arquitetural documentada.

## Critério para iniciar a Fase 1

- inventário Firebase conhecido;
- todas as jornadas associadas a endpoint existente ou contrato proposto;
- padrões de transporte e erro definidos;
- ambientes e reset documentados;
- regressão de novos imports Firestore bloqueada automaticamente.

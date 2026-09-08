# Linha de base de qualidade e segurança

Data: 1 de setembro de 2026.

## Validações executadas

```powershell
flutter test --no-pub
dart analyze --format machine
```

Resultado:

- 4 testes aprovados;
- 0 testes falhando;
- 0 erros do analisador;
- 3 warnings;
- 295 infos/lints;
- teste arquitetural confirmou exatamente 47 arquivos legados com import de Cloud Firestore e nenhum import novo fora da linha de base.

O arquivo `test/widget_test.dart` foi removido porque era um template integralmente comentado e sem `main()`, o que fazia a descoberta padrão do Flutter falhar antes de executar a suíte.

## Warnings existentes

1. import não utilizado de `chat_enums.dart` em `delivery_provider.dart`;
2. import não utilizado de `chat_args.dart` em `delivery_provider.dart`;
3. campo `_reviewsCache` não utilizado em `product_review_provider.dart`.

Esses warnings não foram introduzidos pela Fase 0. A remoção sistemática de warnings, APIs depreciadas, problemas com `BuildContext` assíncrono e demais lints está prevista na Fase 10, ou antes quando o arquivo for tocado por uma migração de domínio.

## Cobertura atual

- três testes unitários do modelo de tentativas/bloqueio de login;
- um teste de arquitetura para impedir crescimento do acoplamento Firestore;
- nenhuma suíte de integração do aplicativo;
- nenhuma jornada cliente/entregador automatizada;
- nenhuma cobertura de contratos HTTP ou Socket.IO no mobile.

Cada fase seguinte deve adicionar testes do código novo. Não é aceitável aguardar a Fase 10 para começar a cobertura da refatoração.

## Riscos de segurança identificados

| Risco | Tratamento planejado |
|---|---|
| Regras Firestore/Storage não versionadas | Firestore operacional será removido; qualquer Storage remanescente exigirá regras versionadas |
| Autorização e perfil consultados no cliente | Backend/PostgreSQL serão autoridade na Fase 2 |
| Status de pedidos/entregas alterados diretamente no Firestore | Migrar comandos para backend nas Fases 5 e 6 |
| Médias de avaliação recalculadas no cliente | Backend calcula e persiste na Fase 3/6 |
| Imagens em Base64 dentro de documentos | Upload multipart/objeto e metadados no PostgreSQL na Fase 4/6 |
| Token FCM no documento Firestore do usuário | Registrar no backend na Fase 8 |
| Localização sem política central de frequência/retenção | Definir e validar no backend na Fase 6 |
| Ausência de App Check no backend customizado | Implantar após autenticação/API estáveis na Fase 8 |
| Pouca cobertura automatizada | Testes incrementais em todas as fases e homologação final |

## Dependências

O `flutter test` sem `--no-pub` tentou resolver novamente o grafo com a versão local do Flutter e informou várias versões mais recentes incompatíveis com as restrições atuais. Nenhuma atualização de dependência ou alteração do `pubspec.lock` foi mantida nesta fase.

Atualizações de Flutter/Firebase serão feitas separadamente, com matriz de compatibilidade, build Android/iOS e testes. Não serão misturadas com a fundação da API.

No Windows, operações que recompõem plugins podem exigir o Developer Mode para suporte a symlinks. Isso deve constar nos pré-requisitos da máquina de desenvolvimento.

## Gate das próximas fases

Para todo código novo:

- `dart format` sem diferenças;
- testes novos e existentes passando;
- nenhum novo warning;
- nenhum novo import de Cloud Firestore;
- nenhuma credencial, token ou PII em log;
- cleanup de requisições, streams, timers e sockets;
- documentação do contrato alterado.

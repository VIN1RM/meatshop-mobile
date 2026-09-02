# Roadmap de integração Mobile, Backend e PostgreSQL

## Objetivo

Integrar integralmente o aplicativo Flutter aos serviços do MeatShop, usando o backend NestJS como única porta de entrada para as regras de negócio e o PostgreSQL como fonte única da verdade.

O Firebase continuará sendo utilizado apenas onde agrega valor ao aplicativo mobile:

- Firebase Authentication para login por e-mail, Google e Apple;
- Firebase Cloud Messaging para notificações push;
- Firebase App Check para atestar instâncias legítimas do aplicativo;
- Crashlytics, Analytics e Performance Monitoring, quando configurados;
- outros serviços complementares que não assumam a propriedade dos dados transacionais.

O Firestore deixará de armazenar dados operacionais de usuários, unidades, catálogo, carrinho, pedidos, pagamentos, entregas, chat e avaliações.

## Decisões de arquitetura

```text
Flutter
  |-- HTTPS/REST e Socket.IO --> NestJS --> PostgreSQL
  |-- Firebase Auth -----------> NestJS valida o ID Token
  |-- FCM <--------------------- NestJS envia notificações
  `-- App Check/Observabilidade  Firebase
```

Regras fundamentais:

1. O aplicativo nunca acessa o PostgreSQL diretamente.
2. O NestJS centraliza autorização, validações e regras de negócio.
3. Não haverá sincronização bidirecional entre PostgreSQL e Firestore.
4. Não haverá escrita dupla feita pelo aplicativo.
5. Perfis, papéis e permissões são definidos no PostgreSQL, não no Firebase.
6. Como não existem dados reais, Firestore e PostgreSQL poderão ser resetados e populados novamente com dados de desenvolvimento.
7. Cada fase só será concluída depois dos testes e critérios de aceite correspondentes.

## Estado inicial

- [x] Backend NestJS integrado ao PostgreSQL.
- [x] Painel web integrado ao backend.
- [x] Aplicativo Flutter com fluxos de cliente e entregador.
- [x] Firebase Auth, Firestore e FCM presentes no mobile.
- [x] Chat, notificações e entregas em tempo real presentes no backend.
- [ ] Mobile consumindo a API NestJS.
- [ ] Firebase Auth federado com a autenticação do backend.
- [ ] Firestore removido dos domínios operacionais.
- [ ] Integração ponta a ponta coberta por testes automatizados.

## Fase 0 — Contratos, inventário e reset seguro

**Status:** concluída em 1 de setembro de 2026. Artefatos em `docs/backend-integration/`.

### Entregas

- [x] Inventariar todas as telas, Providers e serviços que acessam Firebase diretamente.
- [x] Mapear cada operação mobile para uma rota existente ou nova rota do backend.
- [x] Definir DTOs, enums, paginação e formato padronizado de erros.
- [x] Definir ambientes local, homologação e produção.
- [x] Documentar o procedimento de reset e seed do PostgreSQL.
- [x] Documentar a limpeza das coleções Firestore de desenvolvimento.
- [x] Criar uma matriz de rastreabilidade tela → Provider → repositório → endpoint.
- [x] Congelar a criação de novos acessos diretos ao Firestore.

### Critério de aceite

Todos os fluxos mobile possuem contrato definido e nenhuma dependência necessária do backend permanece desconhecida.

## Fase 1 — Fundação da API no Flutter

**Status:** concluída em 1 de setembro de 2026. Detalhes em `docs/backend-integration/PHASE_1_API_FOUNDATION.md`.

### Entregas

- [x] Criar um cliente HTTP central com URL configurável por ambiente.
- [x] Padronizar autenticação, headers, timeout, cancelamento e erros.
- [x] Implementar renovação de token com proteção contra requisições concorrentes.
- [x] Armazenar tokens em armazenamento seguro do sistema operacional.
- [x] Criar interfaces de repositório entre Providers e fontes de dados.
- [x] Impedir que telas conheçam Firebase, HTTP ou detalhes de persistência.
- [x] Criar suporte a paginação e cancelamento de pesquisas.
- [x] Preparar feature flags apenas para controlar o corte gradual durante o desenvolvimento.

### Critério de aceite

O aplicativo consulta um endpoint público e um endpoint protegido, trata expiração de sessão e apresenta erros consistentes sem acesso direto das telas à infraestrutura.

Validado por testes automatizados do contrato de `/health`, `/users/me`, Bearer token, renovação após `401`, concorrência, timeout, cancelamento, paginação e erros. A obtenção inicial da sessão via Firebase será conectada na Fase 2.

## Fase 2 — Federação do Firebase Auth com o backend

**Status:** implementada e validada em 1 de setembro de 2026. A conclusão formal permanece pendente da regularização dos gates globais legados documentados em `docs/backend-integration/PHASE_2_FIREBASE_AUTH_FEDERATION.md`.

### Backend

- [x] Centralizar a inicialização do Firebase Admin em um único provider.
- [x] Adicionar identidade Firebase única e opcional ao usuário PostgreSQL.
- [x] Representar corretamente contas locais e contas autenticadas pelo Firebase.
- [x] Criar `POST /auth/firebase/exchange`.
- [x] Verificar integridade, expiração e revogação do Firebase ID Token.
- [x] Vincular contas apenas com identidade e e-mail verificados de forma segura.
- [x] Emitir os access e refresh tokens já utilizados pelo backend.
- [x] Manter perfil, permissões, aprovação e bloqueio como dados do PostgreSQL.
- [x] Coordenar logout e desativação; exclusão definitiva permanece no corte de conta da Fase 10.

### Mobile

- [x] Manter login por e-mail, Google e Apple no Firebase Auth.
- [x] Trocar o Firebase ID Token por uma sessão MeatShop.
- [x] Restaurar e renovar a sessão ao iniciar o aplicativo.
- [x] Concluir dados obrigatórios do perfil por meio da API.
- [x] Remover consultas de papel e perfil feitas diretamente no Firestore quando `FEATURE_BACKEND_AUTH` está ativa.

### Critério de aceite

Cliente, entregador e usuário com os dois perfis entram pelo Firebase e acessam somente os recursos autorizados pelo backend.

## Fase 3 — Marketplace e consultas públicas

**Status:** implementada e validada em 1 de setembro de 2026. A conclusão formal permanece condicionada aos gates globais legados já documentados. Detalhes em `docs/backend-integration/PHASE_3_MARKETPLACE.md`.

### Backend

- [x] Criar listagem pública e detalhes de unidades/açougues.
- [x] Confirmar filtros de unidades por localização e disponibilidade.
- [x] Completar busca de unidades, produtos e categorias.
- [x] Revisar contratos públicos de produtos, categorias, horários e promoções.
- [x] Garantir que somente produtos ativos e com estoque sejam oferecidos.

### Mobile

- [x] Migrar unidades e detalhes do açougue.
- [x] Migrar categorias, produtos e paginação.
- [x] Migrar horários de funcionamento e promoções.
- [x] Migrar busca e filtros combinados.
- [x] Migrar leitura de avaliações.
- [x] Remover os respectivos acessos Firestore quando `FEATURE_BACKEND_MARKETPLACE` está ativa; o fallback permanece durante o corte gradual.

### Critério de aceite

Todo o marketplace exibido pelo mobile reflete os mesmos dados cadastrados pelo painel web no PostgreSQL.

## Fase 4 — Perfil, endereços, mídia e carrinho

**Status:** implementada e validada em 2 de setembro de 2026. Detalhes em `docs/backend-integration/PHASE_4_PROFILE_ADDRESS_CART.md`.

### Entregas

- [x] Migrar leitura e atualização do perfil.
- [x] Migrar cadastro, edição, exclusão e seleção do endereço padrão.
- [x] Definir upload de avatar sem Base64 em documentos de banco.
- [x] Migrar adição, alteração e remoção de itens do carrinho.
- [x] Revalidar no backend preço, atividade, categoria e estoque de cada produto.
- [x] Permitir um carrinho multiunidade, agrupando itens por açougue para gerar pedidos separados na Fase 5.
- [x] Manter no dispositivo apenas estado de apresentação e cache descartável desses domínios.

### Critério de aceite

Perfil, endereços, imagens e carrinho persistem exclusivamente por meio da API e continuam corretos após reinstalar ou usar o aplicativo em outro dispositivo.

Atendido quando `FEATURE_BACKEND_PROFILE_CART=true`; o fallback Firestore permanece temporariamente apenas para rollback durante a migração gradual.

## Fase 5 — Checkout, pedidos e pagamentos

**Status:** implementada e validada em 2 de setembro de 2026. A homologação financeira real do Mercado Pago requer credenciais sandbox externas. Detalhes em `docs/backend-integration/PHASE_5_CHECKOUT_ORDERS_PAYMENTS.md`.

### Entregas

- [x] Migrar criação, histórico, detalhes, cancelamento, agendamento e recompra.
- [x] Criar o pedido no backend a partir do carrinho validado.
- [x] Calcular preços, descontos, cupom e taxa de entrega no servidor.
- [x] Validar e alterar estoque em transação PostgreSQL.
- [x] Implementar o fluxo Mercado Pago ponta a ponta; homologação real depende das credenciais sandbox.
- [x] Tornar webhook/idempotência a confirmação oficial do pagamento.
- [x] Persistir somente IDs tokenizados e metadados seguros de cartões.
- [x] Exibir o código de entrega ao cliente de forma protegida.
- [x] Remover qualquer alteração direta de pedido ou pagamento no Firestore quando a flag da fase está ativa.

### Critério de aceite

Um pedido criado no mobile aparece imediatamente no painel web, respeita estoque e pagamento e percorre todas as transições autorizadas sem divergência.

Validado com checkout sintético multiunidade: dois pedidos no mesmo `checkout_id`, repetição idempotente e cancelamento com restauração transacional. A comprovação de liquidação financeira no ambiente Mercado Pago permanece um gate externo de homologação, sem bloquear a integridade local do domínio.

## Fase 6 — Fluxo completo do entregador

### Backend

- [ ] Completar consulta do perfil atual do entregador.
- [ ] Completar listagem, edição, ativação e exclusão de veículos.
- [ ] Implementar disponibilidade online/offline.
- [ ] Implementar entregas disponíveis, ativa e histórico do entregador.
- [ ] Definir aceite e rejeição de ofertas.
- [ ] Implementar ganhos, resumo e metas do entregador.
- [ ] Revisar frequência, precisão e retenção da localização.

### Mobile

- [ ] Migrar cadastro e acompanhamento da aprovação.
- [ ] Migrar veículos e disponibilidade.
- [ ] Migrar oferta, aceite e entrega ativa.
- [ ] Migrar código de retirada na unidade.
- [ ] Enviar localização apenas com consentimento e durante entrega ativa.
- [ ] Migrar confirmação com o código do cliente.
- [ ] Migrar histórico, avaliações, ganhos e metas.

### Critério de aceite

O entregador conclui do cadastro à entrega final usando somente o backend, enquanto cliente e unidade acompanham o mesmo estado e localização.

## Fase 7 — Chat e atualizações em tempo real

### Entregas

- [ ] Integrar o Flutter ao Socket.IO do backend.
- [ ] Autenticar sockets com a sessão MeatShop.
- [ ] Migrar os três canais de chat autorizados por pedido.
- [ ] Carregar histórico via REST e receber novas mensagens via socket.
- [ ] Implementar leitura, não lidas, digitação, reconexão e recuperação de eventos.
- [ ] Migrar rastreamento e mudanças de status para os gateways do backend.
- [ ] Usar REST como reconciliação após perda de conexão.
- [ ] Remover conversas e tracking do Firestore.

### Critério de aceite

Cliente, entregador e unidade conversam somente nos canais permitidos e recuperam o estado correto após fechar o app, perder rede ou reconectar.

## Fase 8 — Push e serviços Firebase complementares

### Entregas

- [ ] Registrar e atualizar o token FCM no backend após autenticação.
- [ ] Remover token no logout e eliminar tokens inválidos ou inativos.
- [ ] Enviar notificações pelo backend a partir de eventos reais do domínio.
- [ ] Tratar notificações em primeiro plano, segundo plano e app encerrado.
- [ ] Consultar a API ao abrir uma notificação, sem confiar em payload antigo.
- [ ] Implantar App Check no Flutter e validar seu token no backend.
- [ ] Configurar Crashlytics sem registrar dados pessoais ou segredos.
- [ ] Definir eventos mínimos de Analytics com consentimento e finalidade.
- [ ] Configurar Performance Monitoring quando a integração funcional estiver estável.

### Critério de aceite

Push funciona nos estados suportados, tokens são gerenciados no PostgreSQL e Firebase não mantém dados operacionais duplicados.

## Fase 9 — Reset, seed e corte definitivo do Firestore

Como não existem dados reais, não será realizada migração de legado.

### Entregas

- [ ] Parar os ambientes antes do reset.
- [ ] Resetar o PostgreSQL de desenvolvimento de forma controlada.
- [ ] Executar todas as migrations do backend desde uma base vazia.
- [ ] Executar seed mínimo coerente para unidade, catálogo e contas de teste.
- [ ] Limpar as coleções operacionais do Firestore.
- [ ] Preservar apenas os usuários Firebase necessários ao teste ou recriá-los.
- [ ] Remover seeds Firestore e código de compatibilidade temporária.
- [ ] Validar relacionamentos e jornadas completas após o reseed.
- [ ] Documentar contas, cenários e comandos de preparação do ambiente.

### Critério de aceite

Uma instalação limpa sobe com backend e PostgreSQL, o mobile executa todas as jornadas e nenhuma coleção Firestore operacional é recriada.

## Fase 10 — Qualidade, segurança e conclusão

### Entregas

- [ ] Remover dependências Firebase que deixaram de ser necessárias.
- [ ] Garantir que nenhum domínio operacional importe `cloud_firestore`.
- [ ] Criar testes unitários de modelos, repositórios e Providers.
- [ ] Criar testes de integração do backend para contratos mobile.
- [ ] Criar testes Flutter de integração das jornadas críticas.
- [ ] Validar formatação, análise estática, lint e build Android/iOS.
- [ ] Testar rede lenta, offline, timeout, token expirado e reconexão.
- [ ] Testar concorrência de estoque, idempotência e webhooks.
- [ ] Revisar rate limiting, logs, LGPD, retenção e exclusão de dados.
- [ ] Atualizar README, SETUP, Swagger e documentação arquitetural.
- [ ] Executar homologação conjunta de cliente, entregador e unidade.

### Critério de aceite final

- [ ] PostgreSQL é a única fonte de verdade operacional.
- [ ] Web e mobile apresentam o mesmo estado do negócio.
- [ ] Firebase está restrito a identidade, push, proteção e observabilidade.
- [ ] Todas as jornadas críticas possuem cobertura automatizada e evidência de homologação.
- [ ] O projeto pode ser preparado do zero por documentação versionada.

## Ordem recomendada de implementação

1. Fase 0 — contratos e inventário;
2. Fase 1 — fundação da API Flutter;
3. Fase 2 — autenticação federada;
4. Fase 3 — marketplace;
5. Fase 4 — perfil, endereços e carrinho;
6. Fase 5 — pedidos e pagamentos;
7. Fase 6 — entregador;
8. Fase 7 — tempo real;
9. Fase 8 — Firebase complementar;
10. Fase 9 — reset e corte do Firestore;
11. Fase 10 — qualidade e conclusão.

## Definição de pronto por fase

Uma fase somente pode ser marcada como concluída quando:

- o código passou por lint, análise estática e build;
- os testes correspondentes passaram;
- os contratos estão documentados;
- não existe escrita duplicada entre Firestore e PostgreSQL;
- os fluxos de erro e carregamento foram validados;
- existe uma forma documentada de reproduzir o cenário;
- cliente, entregador e unidade observam dados consistentes.

## Fora do escopo desta integração

- sincronização bidirecional contínua entre PostgreSQL e Firestore;
- acesso direto do Flutter ao PostgreSQL;
- armazenamento de número completo de cartão ou CVV;
- regras de autorização mantidas apenas no cliente;
- uso do Firestore como espelho permanente do banco relacional.

# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Projeto ainda não publicado]

---

## [3.0.0] - Em desenvolvimento
### Integração Mobile com Backend e PostgreSQL

### Added
- Gate final da Fase 10 com teste arquitetural de ausência total do Firestore, setup reproduzível, roteiro de homologação e matriz de evidências de qualidade/segurança.
- Consulta autorizada do perfil público do entregador atribuído e estado consolidado de avaliações do pedido.
- Exclusão de conta com revogação de sessões/dispositivos e anonimização transacional dos dados pessoais no PostgreSQL.
- Preparação reproduzível da Fase 9 com seed PostgreSQL idempotente, contas e cenários sintéticos documentados.
- Configuração Firebase versionada com regras que bloqueiam toda leitura e escrita no Firestore após o corte.
- Push FCM sob `FEATURE_BACKEND_FIREBASE_SERVICES`, com registro Android/iOS no PostgreSQL, renovação de token e remoção no logout.
- App Check em todas as chamadas mobile, Crashlytics para falhas fatais, Analytics somente com consentimento e Performance Monitoring configurável.
- Repositório HTTP de notificações e testes de contrato para registro, remoção, atestação e revalidação antes da navegação.
- Seletor de contato no pedido do cliente para iniciar o canal autorizado com o açougue ou, quando atribuído, com o entregador.
- Chat REST e Socket.IO sob `FEATURE_BACKEND_REALTIME`, com três canais por pedido, caixa de entrada, não lidas, leitura, digitação e reconciliação após reconexão.
- Atualizações de status e localização da entrega por salas autorizadas do backend, eliminando polling no fluxo novo.
- Distinção entre entregador autônomo ativo e entregador vinculado sujeito à aprovação da unidade.
- Upload autenticado e validado de até quatro fotos por veículo.
- Fluxo REST do entregador sob `FEATURE_BACKEND_DELIVERY`, cobrindo cadastro, aprovação, veículos, disponibilidade, ofertas, aceite/rejeição, entrega ativa, códigos, histórico, avaliações, ganhos e metas.
- Persistência PostgreSQL de disponibilidade, rejeições individuais de ofertas e metas diária, semanal e mensal, com exclusão lógica de veículos.
- Testes de contrato da Fase 6 para ofertas, disponibilidade e rejeição sem Firestore ou dados pessoais no payload.
- Checkout HTTP completo sob `FEATURE_BACKEND_CHECKOUT`, com cotação autoritativa, criação multiunidade, histórico, detalhe, cancelamento, agendamento e recompra.
- Repositórios de pedidos e pagamentos com `Idempotency-Key`, checkout agregado do Mercado Pago e métodos de pagamento tokenizados.
- Testes de contrato da Fase 5 para checkout com duas unidades, repetição idempotente, pagamento por lote e metadados seguros de cartão.
- Documentação operacional da Fase 5, incluindo ativação, contratos, consistência, segurança e homologação sandbox.
- Repositórios HTTP de perfil, endereços e carrinho, injetados por contratos e ativados por `FEATURE_BACKEND_PROFILE_CART`.
- Upload autenticado de avatar por `multipart/form-data`, com timeout, cancelamento, renovação de sessão e URL resolvida por ambiente.
- Geocodificação de endereço pelo backend a partir do CEP, sem entrada manual de latitude ou longitude.
- Suporte a carrinho único com produtos de múltiplas unidades, quantidades fracionadas e agrupamento por açougue.
- Testes de contratos de perfil, CEP e carrinho, incluindo persistência da limpeza e cenário multiunidade.
- Marketplace público alimentado pelo PostgreSQL, com unidades, detalhes, horários, avaliações e paginação.
- Busca combinada de açougues, categorias e produtos, incluindo filtros de unidade, categoria e preço.
- Repositório mobile de marketplace e testes de contratos públicos e catálogo vendável.
- Federação do Firebase Authentication com `POST /auth/firebase/exchange`, validação de expiração/revogação e sessão MeatShop.
- Identidade Firebase única e opcional no PostgreSQL, perfil incompleto explícito e conclusão cadastral pela API.
- Vínculo inicial de conta local protegido pela senha atual e por e-mail Firebase verificado.
- Repositório Flutter de autenticação federada, restauração da sessão e testes automatizados de troca e vínculo.
- Roadmap completo em 10 fases para tornar o backend NestJS e o PostgreSQL a fonte única dos dados operacionais do aplicativo.
- Inventário rastreável dos acessos Firebase, contratos de API, ambientes, reset seguro e linha de base de qualidade.
- Cliente REST central com URL por ambiente, métodos HTTP, headers JSON, timeout e cancelamento real de requisições.
- Erros tipados para rede, timeout, cancelamento, autenticação, autorização, validação, conflito, limite de requisições, servidor e contrato inválido.
- Sessão MeatShop com access/refresh token, renovação única para chamadas concorrentes e armazenamento seguro no sistema operacional.
- Contrato de repositório para validar os endpoints público `/health` e protegido `/users/me` sem expor infraestrutura à UI.
- Suporte comum a paginação e compatibilidade temporária entre `total_pages` e `totalPages` na borda remota.
- Feature flags de autenticação e marketplace, desativadas por padrão para controlar o corte gradual.
- Testes automatizados da fundação HTTP, sessão, armazenamento seguro, paginação e fronteiras arquiteturais.

### Changed
- Dependências `cloud_firestore` e `firebase_storage`, adaptadores legados, serializadores de snapshots e todos os fallbacks operacionais foram removidos fisicamente.
- Firebase fica restrito a identidade primária, push, App Check, Crashlytics, Analytics consentido e Performance; toda persistência operacional passa obrigatoriamente pela API.
- Frete exibido no checkout passa a vir exclusivamente da cotação autoritativa do backend.
- Todos os domínios migrados passam a usar obrigatoriamente o backend; defines antigos não reativam fallbacks Firestore.
- Seed operacional do Firestore removido e coleções de desenvolvimento apagadas, preservando Firebase Authentication.
- Abertura de push passa a consultar a notificação atual na API e marcar sua leitura, sem confiar no payload recebido.
- Reconexão Socket.IO renova a sessão também quando o servidor encerra a conexão e restaura todas as inscrições.
- Encerrar o acompanhamento de uma entrega agora abandona explicitamente a sala do pedido no backend.
- Contas criadas pela unidade também são provisionadas no Firebase Authentication para acesso ao aplicativo com a mesma credencial.
- Aceite e rejeição de ofertas agora validam vínculo, disponibilidade e estado atual de forma concorrente; consultas de itens foram consolidadas para evitar N+1.
- Cadastro de entregador/veículo e operação diária passam a usar o backend quando a flag da Fase 6 está ativa, preservando o fluxo legado com a flag desligada.
- Ganhos passam a ser derivados de pedidos efetivamente entregues, eliminando lançamento operacional duplicado pelo aplicativo.
- Revisão do pedido passa a usar preços, descontos, cupons e frete calculados pelo servidor quando a Fase 5 está ativa.
- Histórico, rastreamento e recompra do cliente passam a consumir o PostgreSQL por meio da API, sem escrita dupla no Firestore.
- Pagamentos online abrem uma única preferência Mercado Pago para todos os pedidos do mesmo checkout.
- Perfil, endereços e carrinho passam a usar o PostgreSQL por meio da API quando `FEATURE_BACKEND_PROFILE_CART` está ativa, sem escrita dupla no Firestore.
- Carrinho substitui snapshots locais pela resposta revalidada do servidor após cada mutação.
- Consulta de horários e serviços legados deixam de inicializar Firestore quando uma implementação backend foi injetada.
- Unidades passam a aparecer no marketplace imediatamente após a criação.
- Catálogo mobile passa a oferecer somente produtos e categorias ativos com estoque positivo e promoções vigentes quando `FEATURE_BACKEND_MARKETPLACE` está ativa.
- Login por e-mail, Google e Apple passa a usar access/refresh tokens MeatShop quando `FEATURE_BACKEND_AUTH` está ativa, preservando o fluxo anterior com a flag desligada.
- Firebase Admin centralizado e compartilhado entre autenticação e FCM.
- Versão do aplicativo iniciada em `3.0.0+1` durante todo o plano de refatoração.
- Lockfile de dependências normalizado para o SDK do projeto (Flutter 3.35.5 e Dart 3.9.2).

### Security
- Perfil público do entregador só é retornado ao cliente que possui pedido atribuído a ele.
- Exclusão de conta autentica novamente no Firebase antes de anonimizar o PostgreSQL e somente então remove a identidade primária, evitando exclusão parcial iniciada sem prova de senha.
- Regras Firestore `deny all` impedem recriação de dados operacionais e mantêm o Firebase restrito à identidade e serviços complementares.
- App Check pode ser imposto gradualmente no backend; payloads de push contêm somente contexto mínimo e nunca códigos de entrega, conversa, token ou dados pessoais.
- Salas de chat e tracking revalidam usuário ativo e participação no pedido; token em query string deixou de ser aceito e eventos abusivos são limitados.
- Ofertas são visíveis apenas para entregadores vinculados à unidade e não expõem endereço exato ou coordenadas do cliente antes do aceite.
- Disponibilidade exige aprovação e veículo ativo; atualização de localização é limitada à entrega atribuída, com frequência mínima, precisão opcional e retenção de 30 dias.
- Criação de pedidos exige UUID v4 idempotente; estoque e cancelamento são protegidos por transações e bloqueios PostgreSQL.
- Webhook Mercado Pago valida assinatura, tolerância temporal, consulta oficial, moeda e valor antes de confirmar pagamentos.
- Código de entrega é exibido somente ao cliente proprietário, preservado criptografado e verificado por hash.
- Cartões persistem apenas identificadores tokenizados, bandeira e últimos quatro dígitos; número completo e CVV não são armazenados.
- Endereços vinculados a pedidos são preservados, e avatar deixa de ser armazenado como Base64 em documentos operacionais.
- Produto, categoria, preço e estoque são revalidados pelo backend antes de incluir ou alterar itens no carrinho.
- Firebase ID Tokens são verificados com checagem de revogação; tokens e senhas não são registrados em logs.
- Perfil, papel, bloqueio e estado da conta autenticada pelo mobile passam a ser autorizados pelo PostgreSQL no novo fluxo.
- Backup Android desativado para impedir restauração inconsistente de credenciais criptografadas.
- Refresh token só é descartado em falha definitiva de autorização; indisponibilidade temporária de rede não encerra a sessão.
- UI e Providers são impedidos por teste de importar HTTP, armazenamento seguro ou implementações de infraestrutura.

---

## [2.15.0] - 2026-08-20
### Vinculação de Contas Sociais, Segurança de Login e Conclusão de Perfil

### Added
- `LoginAttemptsConstants.attemptsResetDuration`: janela de 5 minutos para expiração do contador de falhas de autenticação.
- `LoginAttemptModel.isBlockedAt()` e `shouldResetAttempts()`: regras testáveis para verificar bloqueio ativo e expiração das tentativas acumuladas.
- Testes unitários de `LoginAttemptModel` cobrindo manutenção da contagem dentro da janela, reinício após expiração e bloqueio ativo.
- `SocialAccountLinkRequiredException`: transporta o e-mail e a credencial social pendente durante a vinculação com uma conta existente.
- `LinkSocialAccountDialog`: confirmação segura da senha da conta original para vincular Google ou Apple no primeiro acesso social.
- `existingAddress` e `existingVehicle` em `CompleteProfileArgs`, permitindo transportar endereço e veículo já cadastrados para a tela de conclusão.
- `hasChosenProfile(uid)` no `AuthService`: diferencia contas sociais novas de contas existentes que já possuem um tipo de perfil definido.

### Changed
- `LoginAttemptsService.guardLogin()`: remove registros expirados do Firestore antes de liberar uma nova tentativa.
- `LoginAttemptsService.registerFailedAttempt()`: reinicia a contagem quando a última falha ocorreu fora da janela configurada.
- Login com Google e Apple agora verifica contas existentes em `unique_emails`, trata `account-exists-with-different-credential` e vincula o provedor social ao usuário original com `linkWithCredential()`, preservando o mesmo `uid` e seus dados.
- A primeira vinculação social exige a senha da conta existente e respeita o mesmo limite de tentativas e bloqueio temporário do login convencional.
- Duplicatas sociais antigas e sem dados completos são removidas antes da vinculação; contas duplicadas que já possuam dados são preservadas e direcionadas para unificação assistida, evitando perda de informações.
- `AuthProvider._afterSocialLogin()`: carrega usuário, endereço e veículo existentes antes de abrir a conclusão do perfil e mantém bloqueado o tipo de perfil já escolhido.
- `CompleteProfileScreen`: nome, CPF, celular, endereço e veículo existentes são reutilizados; o formulário exibe e valida somente os dados ausentes.
- `PendingProfileDialog` e `CompleteProfileScreen`: botão, gesto e ação de voltar bloqueados enquanto a conclusão obrigatória estiver pendente.
- `client_shell.dart` e `delivery_shell.dart`: passam a verificar e carregar endereço e veículo para perfis `BOTH`, encaminhando os dados existentes pela rota.
- `VehicleEditModal`: novo modo `persistChanges: false` para coletar os dados durante o cadastro e persistir somente na confirmação final.

### Fixed
- Corrigido bloqueio imediato após uma única senha incorreta quando o usuário já havia atingido cinco falhas dias ou meses antes.
- Corrigida criação de um novo usuário ao entrar com Google ou Apple usando o e-mail de uma conta convencional existente.
- Corrigido retorno à aplicação pelo botão ou gesto de voltar antes de concluir dados obrigatórios do perfil.
- Corrigida solicitação repetida de nome, CPF, celular, endereço, veículo e tipo de perfil que já estavam cadastrados.
- Corrigida duplicação de endereço e veículo durante a conclusão de perfis pendentes.
- Corrigido o perfil `BOTH` para exigir e salvar endereço de cliente e veículo de entregador no mesmo fluxo.


---

## [2.14.0] - 2026-07-21
### Fluxo de Onboarding no Primeiro Acesso

### Added
- `OnboardingScreen`: novo tutorial de 4 slides cobrindo seleção de açougue, carrinho/pedido, agendamento de entrega e rastreamento em tempo real, com indicador de progresso, ação de "Pular" e botão principal "Próximo"/"Começar".
- `OnboardingSlide`: modelo de dados leve (título, descrição, ícone) usado para popular os slides do onboarding.
- Rota `AppRoutes.onboarding` registrada em `buildRoutes()`.
- `WelcomePage._checkFirstAccess()`: verifica a flag `hasSeenOnboarding` via `SharedPreferences` no `initState` e navega automaticamente para o `OnboardingScreen` quando o usuário ainda não completou o tutorial.
- Flag `hasSeenOnboarding` persistida via `SharedPreferences` ao finalizar ou pular o onboarding, impedindo que ele seja exibido novamente nas próximas aberturas do app.

### Changed
- `WelcomePage.initState()`: agora dispara `_checkFirstAccess()` logo após a configuração existente do carrossel/timer, usando `WidgetsBinding.instance.addPostFrameCallback` para evitar navegação durante a fase de build.

---

## [2.13.0] - 2026-07-03
### Login Social (Google/Apple), Prevenção de Duplicidade e Checagem de Perfil Pendente

### Added
- `loginWithGoogle()` e `loginWithApple()` no `AuthService`: autenticação via `google_sign_in` e `sign_in_with_apple`, com geração de nonce e hash SHA-256 para o fluxo Apple.
- `_handleSocialUser()` no `AuthService`: cria documento em `users` automaticamente no primeiro login social (`app_profile: CLIENT`, `profile_complete: false`), ou retorna o `app_profile` existente em logins subsequentes.
- `isSocialProfileComplete(uid)` no `AuthService`: verifica se o usuário social já completou CPF/perfil.
- `completeSocialProfile()` e `completeSocialProfileWithVehicle()` no `AuthService`: completam dados obrigatórios (nome, CPF, celular) e, quando aplicável, cadastro de veículo do entregador, com checagem de unicidade de CPF/telefone.
- `CompleteProfileScreen`: nova tela para usuários vindos de login social, com seleção de tipo de perfil (Cliente, Entregador, Cliente & Entregador), formulário de dados pessoais com máscaras de CPF/celular, seleção de veículo (entregador) e endereço (cliente).
- `loginWithGoogle(context)` e `loginWithApple(context)` no `AuthProvider`: orquestram login social, carregamento de `UserProvider`/`UserPreferencesProvider`/`PaymentProvider` e redirecionamento condicional para `CompleteProfileScreen` quando o perfil está incompleto.
- `completeProfileWithType()` no `AuthProvider`: persiste perfil escolhido, dados de veículo ou endereço padrão conforme o tipo selecionado.
- Botões "Continuar com Google" e "Continuar com Apple" na `LoginPage`, com estados de carregamento independentes (`_isGoogleLoading`, `_isAppleLoading`).
- `AppRoutes.completeProfile` registrada em `buildRoutes()`.
- `isEmailAvailable(email)`, `isCpfAvailable(cpf)`, `isPhoneAvailable(phone)` e `findDuplicateField()` no `AuthService`: verificação de duplicidade de CPF, e-mail e celular antes da criação de conta, utilizando coleções públicas de índice (`unique_cpfs`, `unique_phones`, `unique_emails`).
- Coleção `unique_emails` registrada em `_registerUniqueFields()` no `AuthService`, junto a `unique_cpfs` e `unique_phones`, garantindo unicidade também para e-mail.
- Regra de segurança do Firestore para a coleção `unique_emails` (leitura pública, escrita autenticada).
- `UserExistsDialog`: novo dialog exibido quando o CPF, e-mail ou celular informado no cadastro já pertence a outra conta, com redirecionamento automático para o login (e-mail pré-preenchido) quando o campo duplicado é o e-mail.
- Parâmetro `onEmailExists` adicionado a `registerClient()`, `registerDelivery()` e `registerBoth()` no `AuthProvider`, capturando o código `email-already-in-use` do Firebase Auth como rede de segurança e exibindo o `UserExistsDialog` em vez do dialog genérico de erro.
- `RegisterPage`: checagem de duplicidade (`findDuplicateField`) executada antes do envio do formulário de cadastro, bloqueando a criação da conta e exibindo o `UserExistsDialog` quando necessário.
- `LoginPage`: campo de e-mail agora é pré-preenchido automaticamente via argumento de rota quando o usuário é redirecionado a partir do `UserExistsDialog`.
- `PendingProfileChecker`: utilitário que verifica se o usuário autenticado possui dados pendentes de preenchimento (nome, CPF, celular, veículo ou endereço) conforme o `app_profile` ativo.
- `PendingProfileDialog`: dialog exibido ao usuário quando dados obrigatórios do perfil estão incompletos, direcionando para a `CompleteProfileScreen`.
- `existingUser` adicionado ao `CompleteProfileArgs`, permitindo que a `CompleteProfileScreen` receba o `UserModel` já carregado ao ser aberta a partir do fluxo de pendências.
- Carregamento de `AddressProvider` (cliente) e `VehicleProvider` (entregador) em `client_shell.dart` e `delivery_shell.dart` antes da checagem de pendências, substituindo o placeholder fixo anterior.

### Changed
- `AuthProvider._redirectAfterLogin()`: reaproveitado também no fluxo de login social após a conclusão do perfil.

---

## [2.12.0] - 2026-06-27
### Chat: Lista de Conversas e Identificação de Participantes

### Added
- `_DeliveriesShimmer`: shimmer de carregamento na `DeliveriesScreen` substituindo o `CircularProgressIndicator` enquanto o stream de pedidos ativos carrega.
- `_DeliveryPersonCardShimmer`: shimmer de carregamento no `DeliveryPersonCard` substituindo o skeleton estático enquanto os dados do entregador são buscados.
- `_OrderCardShimmer`: shimmer de carregamento no `OrderCardWidget` para exibição durante o carregamento dos pedidos disponíveis para o entregador.

### Changed
- `conversationsStream` no `ChatService`: query simplificada para filtrar conversas pelo ID do documento (`uid1_uid2`) em vez de depender do campo `participant_ids`, tornando a lista compatível com documentos criados sem esse campo.
- `otherParticipant()` no `ChatConversation`: fallback adicionado para extrair o ID do outro participante a partir do ID do documento quando o campo `participant_ids` está ausente, e criação de `ChatParticipant` mínimo com nome inferido pelo tipo quando o campo `participants` também está ausente.
- `_inferName()` e `_inferType()` movidos para dentro da classe `ChatConversation` como métodos privados de instância, corrigindo acesso ao campo `participants`.
- `ChatProvider`: adicionados campos `currentUserName`, `currentUserType`, `receiverName`, `receiverType`, `currentUserPhoto` e `receiverPhoto` ao construtor.
- `ChatProvider._init()`: passa a chamar `getOrCreateConversation()` antes de iniciar o stream de mensagens, garantindo que o documento da conversa exista no Firestore com os campos `participants` e `participant_ids` preenchidos corretamente.
- `ChatScreen`: construção do `ChatProvider` atualizada para passar os novos campos de nome, tipo e foto dos participantes.
- Label "Chats com estabelecimentos" na `AccountScreen` alterado para "Chats".
- Subtítulo da `ChatListScreen` alterado de "Suas conversas" para "Todas as suas conversas".

### Fixed
- Lista de chats exibia "Nenhuma conversa ainda" mesmo com conversas existentes no Firestore, causado por query com `where('participant_ids', arrayContains: ...)` em documentos sem esse campo.
- Nome dos participantes exibido como "Usuário" para todos na lista de chats, causado por `_inferName` e `_inferType` sendo funções soltas fora da classe sem acesso ao mapa `participants`.
- Conversas não apareciam na lista mesmo após o log confirmar recebimento (`recebeu 3 conversas`), causado por `otherParticipant()` retornando `null` para documentos sem o campo `participants`.

---

## [2.11.0] - 2026-06-25
### Entregador Identificado, Avaliações de Produtos e Padronização de Status

### Added
- `ReviewCard`: redesign completo com avatar de iniciais, estrelas arredondadas, data inline no header e suporte a `darkMode` (fundo escuro) e modo claro (fundo branco).
- `UnitReviewsScreen`: refatorada para seguir o padrão visual da Home — `background.png` + `AppHeader(showBack: true)` substituindo o `AppBar` nativo.
- Seção `_buildReviewsSection()` na `ButcherDetailScreen`: três estados visuais — vazio ("Seja o primeiro a avaliar"), poucos reviews (1–2, com banner CTA "Deixe sua avaliação") e completo (3+, com botão "Ver todas" inline ao título).
- `_buildEmptyReviews()`: card centralizado com ícone de estrela, título e subtítulo incentivando a primeira avaliação (`width: double.infinity`).
- `_buildFewReviewsCta()`: banner sutil exibido abaixo dos cards quando há 1 ou 2 avaliações.
- Dividers vermelhos semitransparentes entre seções na `ButcherDetailScreen`.
- `watchProductReviews(productId, {limit})` adicionado ao `ReviewService`.
- Seção de avaliações do produto na `ProductDetailScreen`: mesmos três estados visuais da seção de açougue.
- `ProductReviewsScreen`: nova tela com `AppHeader(showBack: true)` e `background.png`, padrão visual idêntico à `UnitReviewsScreen`.
- `AppRoutes.productReviews` registrado em `buildRoutes()`.
- `productId` adicionado como parâmetro opcional ao `submitReviews` no `ReviewService` (substituindo `null` fixo).
- `DeliveryPersonInfoModel`: modelo com nome, foto, tipo/modelo/placa/cor do veículo e lista de URLs de fotos.
- `DeliveryPersonInfoService`: serviço que busca dados do entregador em `delivery_persons/{id}`, veículo ativo em `vehicles/` e nome/foto em `users/{userId}`.
- `DeliveryPersonCard`: widget exibido na `DeliveriesScreen` quando o pedido está em rota (`OUT_FOR_DELIVERY`), mostrando avatar do entregador (com suporte a base64), nome, tipo e modelo do veículo, badge de placa e foto do veículo em largura total. Foto do entregador e foto do veículo abrem em tela cheia via `ProfilePhotoViewerScreen` ao toque.
- Campo `productsReviewed` adicionado ao `OrderModel` (construtor, `copyWith`, `toFirestore`, `fromFirestore`).
- `submitMultipleProductReviews` no `ProductReviewService`: seta `products_reviewed: true` no documento do pedido via batch atômico junto com os reviews.
- `_recalcProductRating` no `ProductReviewService`: persiste `average_rating` e `review_count` na coleção `products` após cada avaliação.
- `color` e `icon` adicionados como getters à extension `OrderStatusX`, centralizando cor e ícone de cada status em `order_status_enum.dart`.

### Changed
- Botão "Ver todas" movido para inline com o título da seção via `Row + Expanded`, responsivo para qualquer largura de tela.
- Preview de reviews limitado a 3 itens na `ButcherDetailScreen`.
- `darkMode: false` aplicado aos cards na `UnitReviewsScreen` para manter fundo branco.
- Padding inferior da seção de reviews aumentado para 100px, evitando sobreposição com a sacola flutuante.
- `withOpacity` substituído por `withValues(alpha:)` nos widgets de reviews.
- Callbacks `errorBuilder` corrigidos de `(_, __, ___)` para `(_, __, _)`.
- `_statusInfo` na `DeliveriesScreen` e `_activeStatusInfo` na `OrdersScreen` refatorados para consumir `OrderStatusX.color` e `OrderStatusX.icon` diretamente, eliminando duplicação de mapeamento.
- Botão "Produtos" nos cards de pedidos finalizados na `OrdersScreen` agora é ocultado quando `order.productsReviewed == true`, impedindo avaliação duplicada.
- Nome do entregador no `DeliveryPersonCard` exibido com inicial maiúscula via `_capitalize`.
- Foto do veículo no `DeliveryPersonCard` expandida para largura total (`double.infinity`, altura `160`).

### Fixed
- `_reviews` e `_reviewService` não declarados no `State` da `ProductDetailScreen`.
- Card de empty state não centralizado horizontalmente (ausência de `width: double.infinity`).
- `_recalcProductRating` no `ProductReviewService` não persistia o resultado calculado; corrigido com `update` na coleção `products`.
- Avatar do entregador no `DeliveryPersonCard` não renderizava fotos em base64; corrigido com suporte a `Image.memory` além de `Image.network`.

---

## [2.10.0] - 2026-06-22
### Avaliações, Ordenação por Estrelas e Melhorias nos Filtros de Cortes

### Added
- `ReviewModel` e `DeliveryReviewModel`: modelos de dados para avaliações de açougue e entregador com serialização completa para o Firestore.
- `ReviewService`: serviço com persistência no Firestore via batch atômico, prevenção de avaliação duplicada via flag `reviewed` no pedido e recálculo automático de `average_rating` nas coleções `units` e `delivery_persons` após cada avaliação.
- `ReviewProvider`: provider com gerenciamento de estado de carregamento, erro e controle de submissão.
- `ReviewScreen`: tela de avaliação em duas etapas — açougue primeiro, entregador em seguida — com seletor de estrelas interativo, campo de comentário opcional (máx. 200 caracteres), indicador de progresso entre etapas, tela de sucesso animada e navegação via `ReviewArgs`.
- `ReviewArgs`: classe de argumentos de navegação contendo `OrderModel`, `deliveryPersonId`, `unitImageUrl` e `deliveryPersonPhotoUrl`.
- `_AvatarWidget`: widget reutilizável que exibe foto real do açougue ou do entregador no cabeçalho do card de avaliação, com fallback para ícone genérico em caso de erro ou URL vazia.
- `_StepIndicator`: widget de indicador de etapas com círculos numerados e linha conectora, exibido apenas quando há entregador para avaliar.
- `_StarSelector`: widget de seleção de estrelas de 1 a 5 com feedback visual imediato.
- Botão "Avaliar" adicionado aos cards de pedidos finalizados na `OrdersScreen`, visível apenas para pedidos com status `DELIVERED` e `reviewed: false`.
- Campo `reviewed` adicionado ao `OrderModel` com suporte a `fromFirestore` e `copyWith`.
- Campo `deliveryPersonId` adicionado ao `OrderModel` com suporte a `fromFirestore` e `copyWith`.
- Rota `AppRoutes.review` registrada em `buildRoutes()`.
- `ReviewProvider` registrado no `MultiProvider`.
- `averageRating`: campo adicionado ao `UnitModel` com leitura do Firestore e exibição da nota real nos cards de açougue na home e na listagem.
- `review_count`: campo adicionado ao `UnitModel` para exibição da quantidade de avaliações.
- `UnitService.getAllUnits()`: consulta agora ordena os açougues por `average_rating` de forma decrescente diretamente no Firestore.
- `AcouguesScreen._aplicarFiltro()`: ordenação por "Maior ★" e "Menor ★" agora funciona de fato, utilizando o campo `averageRating` do modelo.
- `_buildAcougueItemFromUnit` na `HomePage`: nota real do açougue agora é exibida ao lado da estrela no card, com fallback `–` quando não há avaliações.
- Telas de listagem de cortes (`CutsScreen`) e filtro (`CutsFilterSheet`) migradas para inglês e alinhadas ao padrão visual e de UX da tela de açougues.
- Botão de filtro na `CutsScreen`: fica vermelho e exibe badge amarelo quando há filtro ativo, igual ao comportamento da `AcouguesScreen`.
- Label do filtro na `CutsScreen`: exibe sempre pelo menos a ordenação atual, nunca fica em branco.
- Empty state de cortes: diferencia "nenhum corte nessa faixa de preço" de "nenhum corte encontrado", com link "Limpar filtros" quando aplicável.
- `CutsFilterSheet`: rodapé agora exibe par de botões "Limpar / Aplicar Filtro", padrão do `AcougueFilterSheet`.

### Changed
- `OrdersScreen`: botão de ação dos pedidos finalizados expandido para exibir "Avaliar" (amarelo) ao lado de "Pedir novamente", com lógica condicional baseada em `isCancelled` e `reviewed`.

---

## [2.9.0] - 2026-06-16
### Checkout, Taxa de Entrega, Acompanhamento de Pedidos e Melhorias no Fluxo de Entrega

### Added
- Criados utilitários para centralizar e facilitar futuras funções reutilizáveis do aplicativo.
- `CheckoutReviewScreen`: adicionada lógica para calcular a taxa de entrega por unidade/açougue durante a revisão do pedido.
- `ConfirmOrderButton`: adicionado estado de carregamento ao confirmar pedido, evitando múltiplos cliques durante o processamento.
- `OrderTrackingScreen`: adicionada exibição de data no acompanhamento dos pedidos.
- Adicionada mensagem do usuário no fluxo de pedidos/entrega.
- `activeOrderStream`: adicionados novos status para ampliar o acompanhamento de pedidos ativos.

### Changed
- Melhorado o fluxo de criação de pedidos para incluir corretamente a taxa de entrega.
- Ajustada a navegação a partir do carrinho para buscar os dados completos de produto e unidade.
- Melhorada a estrutura interna com utils preparados para futuras funcionalidades.

### Fixed
- Corrigida a definição da taxa de entrega durante a criação do pedido.
- Corrigido o cálculo da taxa de entrega por unidade na tela de revisão.
- Corrigido problema ao rejeitar pedidos no fluxo de entrega.
- Corrigido o carregamento completo de produto e unidade ao navegar a partir do carrinho.
- Corrigidos problemas no preenchimento automático por CEP e na definição de endereço padrão.

---

## [2.8.0] - 2026-06-12
### Receitas, Melhorias no Carrinho, Perfil e Segurança de Login

### Added
- Adicionado novo domínio de receitas com integração ao Firestore.
- Criadas telas de receitas para exibição de dicas e detalhes com dados reais do banco.
- `RecipeTipsScreen`: integrada com dados em tempo real do Firestore.
- `RecipeDetailsScreen`: adicionados ajustes visuais para melhorar a apresentação das informações da receita.
- `CartScreen`: adicionada exibição da imagem da unidade/açougue no carrinho.
- Adicionada navegação para a tela de detalhes do produto a partir do carrinho.
- `EditProfileScreen`: adicionada passagem de `photoUrl` para o `AvatarPickerSheet`, garantindo exibição correta da foto atual do usuário.
- Adicionado fluxo temporário de bloqueio de login após tentativas falhas.

### Changed
- Melhorada a navegação para a tela de produto.
- Ajustados textos da interface para melhorar clareza e consistência.
- `ProductDetailScreen`: removida a exibição da marca na seção de informações do produto.

### Fixed
- Corrigida a navegação para a tela de produto.
- Corrigida a exibição da imagem da unidade/açougue no carrinho.
- Ajustado o fluxo de autenticação para bloquear temporariamente novas tentativas de login após múltiplas falhas.

---

## [2.7.0] - 2026-06-08
### Padronização Visual dos Bottom Sheets e Melhorias de Responsividade

### Added
- `VehicleEditModal`: detecção de alterações via `_hasChanges` — botão "Salvar alterações" permanece desabilitado até que o usuário modifique algum dado (tipo, campos de texto ou fotos).
- `VehicleEditModal`: `PopScope` adicionado para interceptar gesto de fechar; alterações não salvas são descartadas silenciosamente ao arrastar o sheet para baixo.
- `CartBagSheet`: bottom sheet de prévia do carrinho com itens agrupados por açougue, controles de quantidade inline, total estimado e botão de atalho para o carrinho completo.
- `ProductDetailScreen`: botão flutuante de sacola exibido no canto superior direito quando o carrinho possui itens, abrindo o `CartBagSheet` ao tocar.
- `ButcherDetailScreen`: barra flutuante de sacola exibida na parte inferior da tela quando o carrinho possui itens, com contador de itens e total estimado, abrindo o `CartBagSheet` ao tocar.
- `AppRoutes.cart`: rota nomeada registrada em `buildRoutes()` para navegação direta à `CartScreen`.

### Changed
- `CancelOrderDialog`: migrado para tema claro com fundo `#F5F5F5`, superfícies `#EAEAEA`, textos escuros e bordas neutras, alinhado ao padrão visual da aplicação.
- `VehicleEditModal`: migrado para tema claro, substituindo todas as cores escuras por equivalentes do sistema de design claro.
- `AvatarPickerSheet`: migrado para tema claro com botões de opção em superfície `#EAEAEA` e textos escuros.
- `AcougueFilterSheet`: migrado para tema claro com chips de filtro padronizados.
- `ChatParticipantSheet`: migrado para tema claro com tiles de participante adaptados.
- `DeliveryDetailsSheet`: migrado para tema claro com seções, dividers e botão de fechar padronizados.
- `PaymentCardFormSheet`: migrado para tema claro com campos de formulário, toggle de cartão padrão e botão de salvar padronizados.
- Todos os bottom sheets: `maxHeight` agora desconta `viewInsets.bottom` para evitar corte de conteúdo com teclado aberto.
- Todos os bottom sheets estáticos: envolvidos em `ConstrainedBox` + `SingleChildScrollView` para suporte a telas pequenas.
- Padronização global de snackbars: substituídas todas as chamadas nativas de `ScaffoldMessenger`/`SnackBar` pelo utilitário `CustomSnackBar` em arquivos.
- `AppShell` (`_BottomNav`): ícone do carrinho agora exibe badge dinâmico com a contagem de itens via `CartProvider`; badge oculto quando o carrinho está vazio e exibe "9+" quando a contagem excede 9.

---

## [2.6.0] - 2026-06-05
### Notificações Push, Preferências do Usuário e Ganhos em Tempo Real

### Added
- Implementado módulo de notificações no aplicativo.
- Adicionado suporte ao recebimento de notificações via Firebase Cloud Messaging.
- Criado banner customizado de notificação em primeiro plano.
- Adicionado overlay estilizado para notificações dentro do app.
- Implementado histórico de notificações com leitura via Firestore.
- Adicionado contador de notificações não lidas.
- Implementada marcação individual de notificação como lida.
- Implementada marcação de todas as notificações como lidas.
- Adicionado salvamento automático do token FCM no login do usuário.
- Adicionado suporte à atualização automática do token FCM quando ele for renovado.
- Criado `UserPreferences`: model central de preferências locais do usuário.
- Criado `UserPreferencesService`: serviço genérico de persistência via SharedPreferences, extensível para qualquer preferência futura.
- Criado `UserPreferencesProvider`: provider que expõe e persiste as preferências do usuário para a UI.
- Implementado controle de preferências de notificação por tipo (Pedidos, Entrega, Promoções, Sistema) na tela de Configurações.

### Changed
- Ajustado fluxo de notificações em primeiro plano para exibir banner customizado em vez da notificação padrão do sistema.
- Melhorada a navegação ao tocar em notificações de pedido, entrega e promoção.
- Padronizado o canal Android de notificações do MeatShop.
- `NotificationService`: handler de foreground agora respeita as preferências de notificação do usuário antes de exibir o banner.
- `OrderStatusNotificationWatcher`: exibição de notificações de mudança de status agora respeita a preferência `notifOrders` do usuário.
- `SettingsScreen`: toggles de notificação agora persistem estado real via `UserPreferencesProvider`, substituindo estado local volátil.
- `DeliveryEarningsService`: ganhos agora são registrados automaticamente no Firestore ao concluir uma entrega via `confirmDelivery()`, eliminando dados mockados.
- `DeliveryEarningsProvider`: streams de ganhos e metas migrados para Firestore em tempo real via `DeliveryEarningsService`, substituindo valores fixos.
- `ReportExportService`: campo `time` substituído por `createdAt` formatado do `DeliveryEarningModel`; import não utilizado de `earning_entry.dart` removido.
- `MiniBarChart`: corrigido crash de `NaN` nas alturas das barras quando todos os valores são zero, substituindo `maxVal=0` por fallback `maxVal=1`.
- `EarningsTab`: conversão de `List<double>` para `List<BarData>` antes de passar ao `MiniBarChart`, alinhando ao novo contrato da API do widget.
- Regras de segurança do Firestore: adicionadas regras para as coleções `delivery_goals` e `delivery_earnings`.
- `firestore_seed.dart`: adicionadas funções de seed para `delivery_earnings` e `delivery_goals`.

---

## [2.5.0] - 2026-06-02
### Chat em Tempo Real com Firestore e Integração de Pedidos Disponíveis em Tempo Real para o Entregador

### Added
- `ChatConversation`, `ChatMessage` e `ChatParticipant`: modelos de dados para o sistema de chat com suporte a `fromDoc` e serialização completa.
- `ChatArgs`: classe de argumentos de navegação com geração automática do `conversationId` a partir dos IDs dos dois participantes.
- `ChatService`: serviço com todas as operações Firestore do chat — criar ou buscar conversa, stream de conversas, stream de mensagens, envio com batch atômico, marcação de lidas e contagem total de não lidos.
- `ChatListProvider`: provider com stream em tempo real da lista de conversas do usuário autenticado.
- `ChatProvider`: provider da conversa aberta com stream de mensagens, envio e marcação automática de lidas ao abrir a tela.
- `ChatUnreadProvider`: provider global para badge de não lidos no header ou barra de navegação.
- Valor `delivery` adicionado ao enum `ChatParticipantType` com label "Entregador" e ícone 🛵.
- Regras de segurança do Firestore para a coleção `chat_conversations` e subcoleção `messages`.
- `DeliveryOrderService`: serviço dedicado ao fluxo de entregas com os seguintes métodos:
  - `watchAvailableOrders`: stream em tempo real dos pedidos disponíveis no Firestore, filtrando por `delivery_status: WAITING_DELIVERY_PERSON`, `delivery_type: DELIVERY` e `status` nos valores `PENDING`, `CONFIRMED`, `PREPARING` e `READY`.
  - `_buildOrder`: montagem assíncrona do `DeliveryOrder` a partir do documento do pedido, resolvendo nome do cliente via coleção `users`, nome e endereço da unidade via coleção `units`, endereço de entrega via subcoleção `users/{clientId}/addresses` e lista de itens via subcoleção `orders/{orderId}/items`. Inclui guards de ID vazio e `try/catch` por pedido para evitar que um documento inválido derrube os demais.
  - `_fetchItemsLabel`: monta a string de itens no formato `Nx Nome` lendo a subcoleção de itens e o campo `product_snapshot`.
  - `acceptOrder`, `rejectOrder`, `confirmPickup` e `confirmDelivery`: escrevem as transições de status corretas no Firestore.
  - `fetchActiveOrder`: busca pedido em andamento do entregador para restaurar o estado ao reabrir o app.
- Campo `firestoreId` adicionado ao `DeliveryOrder` para referenciar o doc ID do Firestore separadamente do campo `id` inteiro.
- Campos `clientId` e `unitId` adicionados ao `DeliveryOrder`.
- `factory DeliveryOrder.fromFirestore` adicionado ao model.
- `factory AddressModel.fromMap` adicionado ao model para desserialização de mapas embutidos.
- `UnitModel`: adicionado suporte a horários de funcionamento da unidade.
- `ChatService`: integração com autenticação real e correção na persistência de conversas.
- `DeliveryProvider`: histórico de entregas carregado do Firestore com dados reais.

### Changed
- `ChatListScreen`: substituição completa dos dados mockados por stream real do Firestore via `ChatListProvider`. Badge de não lidos dinâmico por conversa.
- `ChatScreen`: refatorado para ler `ChatArgs` via `ModalRoute` no `didChangeDependencies` e consumir `ChatProvider`. Adicionados separador de datas entre mensagens e scroll automático ao receber nova mensagem.
- `ActiveDeliveryScreen`: `_onOpenChat` atualizado para construir `ChatArgs` com `currentUserId` real do `AuthProvider` e `currentUserType` como `delivery`.
- `routes_config.dart`: rota `AppRoutes.chat` simplificada para `const ChatScreen()`, sem passagem de argumentos no construtor.
- Estrutura Firestore migrada de documentos flat na coleção `chats` para coleção `chat_conversations` com subcoleção `messages`, separando metadados de conversa das mensagens individuais.
- `DeliveryProvider`: substituição completa dos dados mockados por integração real com o Firestore.
  - Listas `_pendingOrders` e `_historyOrders` passaram a ser populadas pelo stream do `DeliveryOrderService`.
  - Adicionados `startListeningOrders(uid)` e `stopListeningOrders()` para gerenciar o ciclo de vida da `StreamSubscription`.
  - `_deliveryPersonUid` armazenado internamente e repassado nas chamadas de `acceptOrder`.
  - Todos os métodos de ação (`acceptOrder`, `rejectOrder`, `confirmPickup`, `confirmDelivery`) passaram a chamar o `DeliveryOrderService` em vez de simular delay.
  - `logout` e `switchToClientMode` chamam `stopListeningOrders` antes de navegar.
- `DeliveryShell`: `startListeningOrders` chamado no `initState` via `addPostFrameCallback` com o UID do `AuthProvider`; `stopListeningOrders` chamado no `dispose`.
- `ReleaseNotesDialog`: título da versão agora é lido diretamente do `RELEASES.md` e exibido no topo do conteúdo, sem hardcode. Seção duplicada filtrada para não repetir o título como categoria.
- `ReleaseNote`: adicionado campo `title` ao modelo, populado pelo parser a partir da primeira linha `###` do bloco de versão.
- `ButcherDetailScreen`: tela agora aguarda o carregamento completo de produtos e promoções antes de renderizar o conteúdo, exibindo o loader padrão durante a busca.
- `ProductDetailScreen`: tela agora aguarda o `postFrameCallback` antes de renderizar, evitando flash de conteúdo incompleto.
- `HomeBody`: tela inicial agora aguarda o carregamento de unidades e promoções em paralelo antes de renderizar, exibindo o loader padrão durante a busca.
- `DeliveriesTab`: botão de atualização adicionado tanto na lista de pedidos quanto no estado vazio, com indicador de carregamento e snackbar de feedback de sucesso ou erro.
- `DeliveryProvider`: método `reloadOrders` refatorado para retornar `bool` indicando sucesso, com estado `isReloading` separado do `isLoading`.
- `watchAvailableOrders` no `DeliveryOrderService`: passa a receber o `deliveryPersonUid` como parâmetro e filtra pedidos criados pelo próprio entregador.
- `UnitModel`: adicionados campos de endereço completo (`street`, `number`, `complement`, `neighborhood`) com getter `formattedAddress` para exibição formatada.
- `ButcherDetailScreen`: endereço completo da unidade agora exibido via `unit.formattedAddress` em vez de apenas cidade e estado.
- Seed do Firestore e `_seedUnits`: campos de endereço completo adicionados ao documento da unidade.
- Regras de segurança do Firestore: usuários autenticados agora podem ler documentos de qualquer usuário e seus endereços, necessário para que entregadores resolvam nome e endereço de entrega dos clientes.

### Fixed
- `PromotionService`: removido cast desnecessário de dados do Firestore na busca de promoções.
- `ProductDetailScreen`: removida variável de item de carrinho não utilizada.
- `CartScreen`: corrigido problema na exibição do label do estabelecimento.

---

## [2.4.0] - 2026-06-01
### Integração de Pedidos, Rastreamento e Chat com Estabelecimentos

### Added
- Utilitário de máscaras de entrada criado em `utils`, centralizando formatações reutilizáveis no aplicativo.
- **OrdersScreen:** integração com Firebase Firestore para carregamento dinâmico dos pedidos.
- **AddressScheduleScreen:** integração com Firestore para carregar endereços reais do usuário.
- Busca global com consulta otimizada por *debounce* e resultados de múltiplos tipos.
- **AppBackButton:** componente reutilizável de botão de voltar com navegação segura usando `maybePop`.
- **Carrinho:** adição de produtos diretamente pela `ProductDetailScreen`.
- **Carrinho:** remoção de itens com gesto de deslizar, *dialog* de confirmação e *snackbar* de feedback.
- **Carrinho:** confirmação antes de remover um item ao reduzir a quantidade para zero.
- **Endereços:** *dialog* de confirmação para definir endereço padrão, com *snackbar* de feedback.
- **Endereços:** suporte à atualização de endereço pela *bottom sheet* de endereço de entrega.
- `OrderItemModel`: modelo de dados para itens de pedido com getter `quantityLabel` para exibição formatada de quantidade e unidade.
- `ActiveOrderModel`: modelo leve para rastreamento de pedidos ativos sem carregamento da subcoleção de itens, com getters `isCancelled` e `canCancel`.
- `OrderStatus` (enum): enum com extensão `OrderStatusX` contendo `fromString`, `label` e `canCancel`, extraído para `core/enums/order_status_enum.dart`.
- `OrdersScreen`: integração com Firestore via streams `activeOrdersStream` e `finishedOrdersStream` no `OrderService`, substituindo dados mockados.
- `DeliveriesScreen`: integração com Firestore via stream `activeOrdersTrackingStream`, exibindo pedidos ativos em tempo real sem dados mockados.
- `activeOrdersTrackingStream` no `OrderService`: stream leve para rastreamento de pedidos com busca de nome e logo da unidade sem carregar subcoleção de itens.
- `cancelOrder` no `OrderService`: cancela pedido no Firestore atualizando status, motivo, timestamp e registrando no histórico de status.
- `SelectUnitChatDialog`: dialog de seleção de açougue exibido quando o usuário possui pedidos ativos de mais de uma unidade ao tentar contatar um estabelecimento.
- Botão "Contatar estabelecimento" na `DeliveriesScreen` agora navega diretamente para o chat quando há apenas uma unidade ativa, ou exibe o `SelectUnitChatDialog` para seleção quando há múltiplas unidades.
- `unitId` adicionado ao `ChatArgs` para identificação correta da unidade no chat.
- `unitId` adicionado ao `ChatContact` para navegação correta a partir da `ChatListScreen`.
- Limpeza automática do carrinho no Firestore e no estado local após pedido confirmado com sucesso via `OrderProvider`.

### Changed
- **ChatScreen:** redesign da barra de entrada de mensagem e melhoria geral no layout da tela.
- **CartScreen:** adicionado suporte para editar item ao tocar no produto e divisores visuais entre itens.
- Telas de endereço: padronização visual dos *dialogs* para manter consistência de UI.
- **ChangePasswordScreen:** substituição do botão de voltar customizado por `AppHeader` e `AppBackButton`.
- `OrderModel`: adicionados campos `unitName`, `unitLogoUrl`, `cancellationReason`, `items` e getters computados `isCancelled` e `formattedTotal`. Adicionado `copyWith` para hidratação assíncrona dos dados da unidade.
- `OrderService`: adicionados métodos `_fetchItems`, `_toModelWithItems`, `activeOrdersStream`, `finishedOrdersStream`, `activeOrdersTrackingStream` e `cancelOrder`.
- `OrderProvider`: adicionada dependência de `CartService` e `CartProvider` para limpeza do carrinho pós-pedido. Parâmetro `cartProvider` adicionado ao `placeOrder`.
- `ChatScreen`: `didChangeDependencies` atualizado para aceitar tanto `ChatArgs` quanto `Map` como argumento de rota, eliminando erro de cast de tipo.
- `app_routes_builder.dart`: rota `AppRoutes.chat` atualizada para resolver `unitId` e `unitName` a partir de `Map` ou `ChatArgs`, construindo `ChatArgs` corretamente em ambos os casos.
- `ReviewOrderScreen`: removida chamada duplicada a `cart.clearCart()`, delegando a limpeza ao `OrderProvider`.

### Fixed
- Corrigido problema na busca que podia chamar `notifyListeners` durante o descarte da árvore de widgets.
- Corrigido crash `_TypeError` na `ChatScreen` causado por cast inválido de `Map` para `ChatArgs` ao navegar a partir da `DeliveriesScreen`.
- Corrigido `undefined_identifier 'unit'` na `ChatListScreen` e `ActiveDeliveryScreen`, substituído por `chat.unitId` e `order.unitId` respectivamente.
- Corrigida linha solta `_latestOrders = orders` fora de método na `DeliveriesScreen`, movida para dentro do `StreamBuilder`.

---

## [2.3.0] - 2026-05-30
### Integração de Produtos, Açougues e Carrinho com Firestore

### Added
- `CartItemModel`: modelo de dados para itens do carrinho com suporte a `fromMap`, `toMap` e `copyWith`.
- `CartService`: serviço para buscar, atualizar quantidade e remover itens do carrinho no Firestore.
- `CartProvider`: provider com gerenciamento de estado do carrinho agrupado por açougue, com suporte a loading, erro e estado vazio.
- `ButcherProvider`: provider que carrega produtos e promoções ativas de um açougue específico em paralelo via `Future.wait`.
- `fetchByUnitId` no `ProductService`: busca produtos ativos com estoque disponível filtrando por `unit_id`.
- `fetchActivePromotionsByUnit` no `PromotionService`: busca promoções ativas de uma unidade específica com enriquecimento dos dados do produto.

### Changed
- `CartScreen`: substituição completa dos dados mockados por dados reais do Firestore via `CartProvider`. Itens agrupados por açougue, com controles de quantidade reais, botão de remoção por item e estados de loading, erro e carrinho vazio.
- `ButcherDetailScreen`: reescrita para receber `UnitModel` como argumento de rota, exibindo imagem, nome e cidade/estado reais do açougue. Produtos e promoções carregados do Firestore via `ButcherProvider`.
- Seção de promoções na `ButcherDetailScreen`: carrossel horizontal exibido apenas quando o açougue possui promoções ativas, com badge de desconto e navegação para `ProductDetailScreen`.
- `HomeScreen` e `AcouguesScreen`: navegação para `ButcherDetailScreen` agora passa o `UnitModel` real como argumento.
- Carrossel de promoções na `HomeScreen`: toque nos cards navega para `ProductDetailScreen` montando um `ProductModel` com os dados da promoção.
- `CutsScreen`: subtitle abaixo do nome do produto exibe o nome da unidade (açougue) resolvido via `UnitService`.
- `ProductModel`: adicionado campo `unitName` com suporte a `copyWith` para resolução assíncrona do nome da unidade.

---

## [2.2.0] - 2026-05-28
### Padronização Visual, Refatorações e Melhorias de UX

### Changed
- `PaymentScreen`: padronização do estilo da aba de pagamento e dos cards de método não selecionado, garantindo consistência visual entre as opções.
- `AddressScheduleScreen`: redesign e padronização do layout da tela de endereço e agendamento.
- Botões com melhor responsividade e adaptação a diferentes tamanhos de tela.
- `OrderCardWidget`: cores padronizadas para o tema claro, alinhadas ao padrão visual da `AccountScreen`.
- `ActiveDeliveryScreen`: padronização do layout e extração do dialog de confirmação de entrega para componente dedicado.
- `PersonalManagementScreen` (Ganhos e Relatórios): substituição de `withOpacity` depreciado por `withValues` nos widgets de ganhos e relatórios.

### Added
- `DeliveryConfirmationDialog`: dialog extraído como componente reutilizável em `ui/components/`.
- `OrderDetailsSheet`: bottom sheet de detalhes do pedido extraído para `ui/components/sheets`, seguindo o princípio de responsabilidade única.
- `SettingsScreen`: dialog de Termos de Uso com link externo para a página oficial.

### Fixed
- Corrigido estilo dos cards de método de pagamento não selecionados para seguir o padrão visual da tela.

---

## [2.1.0] - 2026-05-27
### Integração de Açougues com Firestore e Remoção de Dados Mockados

### Added
- `UnitModel`: modelo de dados para açougues com suporte a CNPJ, `image_url` e serialização completa (`fromMap`/`toMap`).
- `UnitProvider`: provider com gerenciamento de estado de carregamento e erro para listagem de unidades.
- `SplashPage`: chamada a `getIdToken()` no splash para renovação silenciosa do ID token expirado antes de restaurar a sessão.
- `AuthProvider.restoreSession()`: método que reidrata o estado de autenticação (`_isAuthenticated`, `_appProfile`) a partir do Firestore e redireciona o usuário para a rota correta sem exigir novo login.
- Fluxo de gerenciamento de endereços salvos do cliente integrado ao Firestore.
- `RemoveAddressDialog`: componente dedicado para confirmação de remoção de endereço salvo.
- Busca automática de endereço por CEP no formulário de cadastro de cliente.

### Changed
- `HomeScreen`: seção de açougues agora exibe até 3 unidades reais do Firestore, removendo os dados mockados anteriores.
- `AcouguesScreen`: listagem completa de açougues migrada para dados reais do Firestore, com suporte a ordenação por nome (A→Z e Z→A).
- Usuários autenticados são redirecionados diretamente para o shell correto (cliente, entregador ou seleção de modo) ao reabrir o app, sem passar pela tela de boas-vindas ou login.
- Fluxo de criação e edição de endereços do cliente atualizado para salvar dados de forma assíncrona no Firestore.
- Cores dos cards padronizadas para o tema claro nas telas de carrinho, pedidos, dicas de receitas e endereços salvos.
- Cor de fundo das telas ajustada para seguir o padrão visual da aplicação.
- Estado de carregamento da lista de açougues atualizado para utilizar o loader padrão da aplicação.
- Formulário de cadastro de cliente atualizado para preencher rua, bairro, cidade e UF automaticamente ao informar um CEP válido.
- `VehicleSettingsScreen`: lista de veículos reais do Firestore exibida por cards com foto do veículo como avatar, refresh automático após edição.
- `VehicleEditModal`: fotos existentes renderizadas corretamente via `Image.memory` para URLs em base64; URLs mantidas/removidas transmitidas ao provider via `keptUrls`, garantindo persistência correta no Firestore.
- `VehicleProvider`: carregamento de todos os veículos da subcoleção em vez de apenas o ativo; `updateVehicle` atualiza somente as URLs preservadas pelo usuário.
- `SettingsScreen`: todas as notificações iniciam desativadas por padrão.

### Fixed
- Corrigido o fluxo de salvamento de endereços para aguardar a conclusão das operações de criação e edição antes de fechar o formulário.
- Corrigido o fluxo de restauração de sessão para manter usuários autenticados após reiniciar o app.
- Corrigida a ausência de preenchimento automático de endereço durante o cadastro de cliente.

---

## [2.0.0] - 2026-05-18
### Integração Firebase, Autenticação Real e Gestão de Perfil

### Added
- Integração completa com **Firebase Auth**: autenticação real de usuários com e-mail e senha, substituindo o fluxo simulado anterior.
- Integração com **Cloud Firestore**: carregamento de dados reais do perfil do usuário (nome, e-mail, celular, CPF) a partir da coleção `users`, removendo todos os dados mockados.
- Integração com **Firebase Storage**: upload de imagens de usuários, produtos e unidades diretamente para o Storage, com URL pública salva no Firestore.
- **Fluxo de exclusão de conta**: dialog de confirmação com reautenticação via senha antes da exclusão definitiva, garantindo segurança na operação.
- **Fluxo de alteração de senha real**: reautenticação do usuário com a senha atual via Firebase antes de aplicar a nova senha, substituindo o fluxo anterior sem validação.
- **Upload de foto de veículo**: upload real das fotos do veículo do entregador para o Firebase Storage durante o cadastro e edição.
- **Dialogs centralizados**: arquivo dedicado de dialogs reutilizáveis integrado à tela de login.
- Lógica de exibição condicional do botão "Alternar modo" no shell: visível apenas para usuários com perfil `both`.
- Reset de senha via E-mail funcionando perfeitamente.

### Changed
- **Foto de perfil**: migração de base64 no Firestore para upload no Firebase Storage, reduzindo o tamanho dos documentos e melhorando a performance de leitura.
- **Cadastro de veículo**: fotos do veículo agora são enviadas ao Firebase Storage em vez de codificadas em base64, alinhando ao padrão de armazenamento de mídia do projeto.
- **`AccountScreen` e `DeliveryAccountScreen`**: dados do perfil carregados diretamente do Firestore em tempo real, sem dependência de estado local mockado.
- `register_screen.dart`: corrigido layout quebrado na seção de endereço — `Row` de Número/Bairro reestruturado, campo de Complemento reposicionado e duplicação do campo Bairro removida.

### Fixed
- Correção de erro ao editar a foto de perfil que impedia a atualização da imagem em determinados fluxos.
- Correção do campo `phone` que não era transmitido corretamente pelo fluxo de registro para todos os tipos de perfil (cliente, entregador e ambos).

---

## [1.6.0] - 2026-05-04
### Fluxo de Checkout Reestruturado, Tela de Endereço de Entrega e Assistente Virtual (Meatshop - Chatbot)

### Added
- `AddressScheduleScreen`: nova tela de seleção de endereço e modalidade de entrega, inserida entre o carrinho e o pagamento. Possui duas abas:
  - **Pedir agora**
  - **Agendar**
- Carrossel de promoções expandindo a quantidade de produtos `HomeScreen`, com scroll infinito contínuo para a direita.
- Toque nos cards do carrossel de promoções navega para `ProductDetailScreen` via rota nomeada.  
- Assistente de receitas com Inteligência Artificial integrado ao aplicativo. **Meatshop - Chatbot**
- `ProductDetailScreen`: seletor de quantidade reformulado com alternância entre gramas (g) e quilos (kg), input numérico livre com botões de incremento (`+50g` / `+0,5kg`) e chips de atalho rápido. Cálculo de total estimado em tempo real na tela de detalhe do produto, exibindo a fórmula `Xg × R$preço/kg` com conversão automática de unidade.
- Botão "Pedir novamente" adicionado aos cards de pedidos finalizados em `OrdersScreen`, disparando o `ReorderConfirmDialog` com os dados do pedido histórico.
- `ReorderConfirmDialog`: dialog de confirmação de pedido, exibindo nome do açougue, lista de itens com quantidades, total do pedido e aviso de variação de preço. Ao confirmar, navega para `AddressScheduleScreen`.

### Changed
- Fluxo de checkout reestruturado. Ordem anterior: Carrinho → Revisão → Pagamento → Processamento. 
  -Nova ordem: Carrinho → Endereço/Agendamento → Pagamento → Resumo → Processamento.

---

## [1.5.0] - 2026-04-30
### Pagamentos, Confirmação de Compra e Gestão do Entregador

### Added
-`PersonalManagementScreen`: tela de gestão pessoal do entregador, acessível pelo shell do entregador, com duas abas — "Ganhos & Metas" e "Relatórios".
-Aba "Ganhos & Metas": card de ganhos em tempo real com badge "AO VIVO", mini gráfico de barras dos últimos 7 dias, cards de metas (diária, semanal, mensal) com barra de progresso animada e edição via bottom sheet, e lista de ganhos recentes com badge "NOVO" na entrada mais recente.
-Aba "Relatórios": seletor de período (Semanal/Mensal), grid 2×2 de métricas (total ganho, entregas, ticket médio, melhor período), botão de exportação e lista de entregas do período.
-`ReportExportService`: serviço estático para geração e compartilhamento de relatórios. Exportação em PDF via pacote pdf (documento A4 com cabeçalho MeatShop, boxes de resumo e tabela -de entregas) e em CSV via pacote csv (estruturado por seções).
- `PaymentScreen`: tela de pagamento com duas abas — "Pagar online" e "Na entrega". Aba online suporta Pix (com instruções de QR Code), cartão de crédito e débito, com listagem de cartões salvos, formulário de novo cartão (com campo de parcelas para crédito) e toggle para salvar cartão. Aba na entrega suporta dinheiro (com toggle e campo de troco), débito e crédito na maquininha, com seleção de bandeira em grid (Visa, Mastercard, Elo, Hipercard, Amex, Cabal) e feedback visual da bandeira selecionada.
- `OrderProcessingScreen`: tela de fallback pós-confirmação de compra com duas fases — carregamento (barra de progresso animada de 5s, percentual em tempo real, ícone pulsante e 4 steps visuais sequenciais) e sucesso (animação elástica no ícone de confirmação, partículas comemorativas e redirecionamento automático para a tela de acompanhamento).
- Padronização do `AppHeader` em todas as telas do aplicativo, garantindo consistência visual no cabeçalho entre os fluxos de cliente e entregador.
- Padronização do `background.png` como imagem de fundo ancorada no topo em todas as telas principais, unificando a identidade visual da aplicação.
- `EditProfileScreen`: tela de edição de dados pessoais. Permite editar nome completo, e-mail, celular e endereço (CEP, rua, número, bairro, complemento, cidade e UF). CPF é exibido como somente leitura.
- `AvatarPickerSheet`: bottom sheet fragmentado para seleção de foto de perfil, com opções de câmera, galeria e remoção da foto atual (exibida condicionalmente apenas quando já existe uma foto definida). Validação de tipo de arquivo integrada, permitindo apenas imagens.
- Botão "Editar dados" adicionado ao card de perfil em `AccountScreen` (cliente) e `DeliveryAccountScreen` (entregador), ambos navegando para a `EditProfileScreen`.

---

## [1.4.0] - 2026-04-26
### Modo Duplo, Mapas e Fluxo Completo de Entrega

### Added
- `ModeSelectionPage`: tela de seleção de modo para usuários com perfil `both`, com layout de tela dividida (superior = Cliente, inferior = Entregador), inspirado em split-screen com imagens de fundo representativas de cada perfil. Animação de zoom com esmaecimento do painel não selecionado e indicador de carregamento (dots pulsantes) com delay de 3 segundos antes da navegação.
- Lógica de redirecionamento pós-login no `AuthProvider` baseada no `app_profile` retornado pelo backend: `client` → shell do cliente, `delivery` → shell do entregador, `both` → tela de seleção de modo.
- Fluxo completo de conta do entregador (`delivery_account_screen.dart`) com card de perfil, estatísticas de entregas e avaliação média, e menu de navegação com acesso a chats, configurações do veículo, configurações gerais, modo cliente e logout.
- Tela de configurações do veículo (`vehicle_settings_screen.dart`) com exibição do veículo cadastrado em modo somente leitura e botão para edição via bottom sheet.
- Bottom sheet de edição de veículo (`vehicle_edit_sheet.dart`) com seletor de tipo de veículo em grid 2x2 (Carro, Moto, Bicicleta, Patinete), campos dinâmicos por tipo (modelo, placa, cor, ano), card de descrição contextual por tipo selecionado, seção de upload de até 3 fotos com indicador de progresso e validação mínima de 3 fotos antes de salvar.
- Integração de mapa interativo na tela de entrega ativa (`active_delivery_screen.dart`) utilizando OpenStreetMap via `flutter_map`, substituindo a dependência do Google Maps.
- Rastreamento em tempo real da localização do entregador com atualização a cada 10 metros via `geolocator`.
- Geocodificação de endereços via API Nominatim (OpenStreetMap), convertendo o endereço do cliente em coordenadas geográficas sem custo.
- Roteamento via API OSRM com exibição da rota de condução como polilinha vermelha no mapa, conectando a posição do entregador ao destino do pedido.
- Adicionado dialog de seleção de fonte de imagem (câmera ou galeria) no modal de edição de veículo
- Fluxo de entrega em duas etapas no `active_delivery_screen.dart`: etapa 1 (retirada no açougue) e etapa 2 (entrega ao cliente), com transição via `confirmPickup()` e indicador visual de etapa ativa/concluída.
- Navegação externa substituindo o mapa in-app: botão "Navegar" em cada etapa abre o Waze (quando instalado) ou o Google Maps como fallback, via `url_launcher`.
- `OrderCardWidget` atualizado para exibir rota visual em duas etapas (açougue → cliente) com ícones e linha conectora distintos para cada ponto.
- `RejectOrderDialog`: dialog de recusa de pedido com seleção múltipla de motivos via `Set<OrderRejectionReason>`. O entregador pode selecionar um ou mais motivos antes de confirmar, com contador dinâmico no botão ("Confirmar (2)") e checkbox animado por tile.
- Enum `OrderRejectionReason` criado em arquivo dedicado (`delivery_enums.dart`) com os motivos: distância excessiva, problema com veículo, área de risco, excesso de itens, valor baixo e outro. Cada motivo expõe `label` e `icon` para renderização.
- Fragmentação do `delivery_provider.dart`: modelo `DeliveryOrder` extraído para `models/delivery_order_model.dart` e todos os enums do fluxo de entrega (`DeliveryAvailability`, `DeliveryOrderStatus`, `DeliveryStep`, `OrderRejectionReason`) extraídos para `core/enums/delivery_enums.dart`.
- `ModeSwitchScreen`: tela de transição exibida ao alternar entre os modos cliente e entregador, com fade-in animado, imagem representativa do perfil de destino e mensagem contextual. Aguarda 5 segundos antes de navegar para a rota de destino recebida via `arguments`. Integrada ao `switchToDeliveryMode` no `AuthProvider` e ao `switchToClientMode` no `DeliveryProvider`.

### Changed
- `AuthProvider` atualizado para rastrear `appProfile` (perfil do backend) e `activeProfile` (perfil ativo na sessão) de forma independente.
- `logout` atualizado para limpar `_appProfile` e `_activeProfile` além do estado de autenticação.
- `rejectOrder()` no `DeliveryProvider` atualizado para receber `List<OrderRejectionReason>` em vez de um único motivo, com log dos motivos selecionados para futura integração com a API.
- `deliveries_screen.dart` atualizado para aguardar o retorno do `RejectOrderDialog` antes de chamar `rejectOrder()`, garantindo que a rejeição só ocorre quando ao menos um motivo é selecionado.

---

## [1.3.0] - 2026-04-22
### Endereços, pagamentos e configurações do usuário

### Added
- Fluxo de gerenciamento de endereços com preenchimento automático via API ViaCEP.
- Modelo de dados `AddressModel` com serialização completa (`fromJson`/`toJson`).
- Componente `address_form_sheet.dart` extraído como componente independente para seguir o princípio de responsabilidade única.
- Integração com a API ViaCEP através do `CepService` utilizando o tipo selado `Result` (`CepSuccess` / `CepFailure`) para tratamento de erros de rede, CEP inválido e timeout.
- Preenchimento automático de logradouro, bairro, cidade e estado ao completar o CEP, incluindo indicador de carregamento e feedback de erro em tempo real.
- Responsividade para telas pequenas utilizando `BoxConstraints` (limite de 92% da altura da tela) combinado com `Flexible` e `SingleChildScrollView`.
- Tela de configurações (`settings_screen.dart`) com seções de notificações, conta, sobre e gerenciamento da conta.
- Implementação do fluxo de adição de cartões com PaymentCardFormSheet, incluindo validação e formatação dos campos c/ integração de bottom sheet para cadastro de novos cartões na tela de pagamentos.
- `ReleaseNotesService` para parsing do `assets/RELEASES.md` por versão, com suporte a cabeçalhos com emojis e datas por extenso `ReleaseNotesDialog` com exibição de seções, ícones e cores por categoria de mudança. `assets/RELEASES.md` com notas de lançamento em linguagem acessível ao usuário final.

### Changed
- `ChatScreen` e `ChatListScreen` foram refatoradas para alinhar ao sistema de design escuro do aplicativo.
- Adicionado cálculo dinâmico do valor total na tela de detalhe do produto, refletindo a quantidade selecionada em tempo real.
- `SplashPage`: trocamos a logo, altura da logo aumentada, textos de boas-vindas centralizados e imagem de fundo adicionada cobrindo a tela toda com opacidade configurável via `BoxFit.cover`.
- `LoginPage`: removido o container circular branco ao redor da logo, que agora é renderizada diretamente sobre o fundo escuro; adicionado `background.png` ancorado na parte inferior da tela via `Stack` + `Positioned` + `Opacity`.

---

## [1.2.0] - 2026-04-15
### Entregas, chat com estabelecimentos e detalhes de produtos

### Added

- Tela de acompanhamento de entrega (`deliveries_screen.dart`).
- Implementação do fluxo de chat com estabelecimentos:
  - Tela de conversa (`chat_screen.dart`) com envio de mensagens e controle de interação.
  - Tela de listagem de chats (`chat_list_screen.dart`) com indicador de mensagens não lidas.
- Tela de detalhes do açougue (`butcher_detail_screen.dart`) com informações institucionais, avaliação, endereço e listagem de produtos.
- Tela de detalhes do produto (`product_detail_screen.dart`) com banner hero, informações do produto, seletor de quantidade e carrossel de sugestões ("Compre também").
- Loading states em ações assíncronas para evitar ansiedade do usuário.

### Changed

- `ButcherDetailScreen`: adicionado `GestureDetector` em cada item de produto para navegar até `ProductDetailScreen` passando o `ButcherProduct` como argumento.
- `WelcomePage` e `AccountScreen` convertidas de `StatelessWidget` para `StatefulWidget` para suportar controle de loading local.

### Fixed
- Correção de uso de `BuildContext` em método auxiliar fora do `build`.
- Ajustes de layout para evitar inconsistências visuais em diferentes dispositivos.

---

## [1.1.0] - 2026-04-09
### Catálogo de cortes, filtros, busca e autenticação com estado global

### Added

- Tela de listagem de acougues (`acougues_screen.dart`) com ordenacao por nome, avaliacao e faixa de preco via bottom sheet de filtro (`butcher_filter_sheet.dart`).
- Tela de cortes bovinos (`bovine_cuts_screen.dart`) com listagem, busca em tempo real e filtro por ordem e faixa de preco.
- Tela de cortes suinos (`swine_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Tela de cortes de aves (`poultry_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Tela de cortes de peixe (`fish_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Widget de filtro reutilizavel para cortes (`cuts_filter_sheet.dart`) com suporte a ordenacao e faixa de preco, compartilhado entre todas as telas de cortes.
- Widget de busca reutilizavel (`search_widget.dart`) com suporte a hint text configuravel, botao de voltar opcional, callbacks `onChanged` e `onSubmitted`, e botao de limpar integrado.
- Tela de acompanhamento de entrega (`deliveries_screen.dart`).
- `AppShell` com `BottomNavigationBar` compartilhado entre as telas principais.
- Implementação do fluxo completo de autenticação utilizando Provider (`AuthProvider`).
- Gerenciamento de estado global de autenticação integrado ao `MultiProvider`.
- Fluxo de login com validação de formulário e integração com provider.
- Fluxo de logout com limpeza de estado e controle de navegação.

### Changed

- `SearchWidget` substituiu as implementacoes duplicadas de search bar em todas as telas: `HomePage`, `AcouguesScreen`, `BovineCortsScreen`, `FishCortsScreen`, `PoultryCortsScreen`, `SwineCortsScreen` e `DeliveriesScreen`.
- `CartScreen` refatorada com remocao da search bar e centralizacao dos chips de metodo de pagamento.
- Indice de tab do `AppShell` corrigido para refletir a aba ativa corretamente em todas as rotas.
- Telas de autenticação (`login_screen.dart` e `account_screen.dart`) refatoradas para uso do Provider (`context.read`).
- Ajustes na arquitetura para suportar gerenciamento de estado com Provider.

---

## [1.0.0] - 2026-03-11
### Estrutura base, fluxo de autenticação e telas iniciais

### Added

- Estrutura inicial do projeto Flutter com suporte a Material 3.
- Tela de Splash (`splash_screen.dart`) com loader animado (`MeatShopLoader`), imagem de fundo com opacidade e logo do MeatShop.
- Tela de Boas-vindas (`welcome_screen.dart`) com carrossel automático de imagens, textos institucionais e botão de navegação para o login.
- Tela de Login (`login_screen.dart`) com campos de usuário e senha, toggle de visibilidade de senha, link "Esqueceu sua senha?" e link para cadastro.
- Tela de Seleção de Tipo de Cadastro (`select_register_screen.dart`) com cards animados para escolha entre perfil Cliente e Entregador.
- Tela de Cadastro (`register_screen.dart`) com campos dinâmicos conforme o perfil selecionado:
  - Campos comuns: nome completo, e-mail, CPF, celular (com máscara `(00) 0 0000-0000`), senha e confirmação de senha.
  - Perfil Cliente: seção de endereço com CEP, rua, número, bairro, cidade e UF.
  - Perfil Entregador: seleção de tipo de veículo em grid (Moto, Bicicleta, Carro, A pé).
- Tela de Alteração de Senha (`change_password.dart`) com campo de e-mail cadastrado, nova senha e confirmação, acessível via "Esqueceu sua senha?" no login.
- Validação de força de senha em tempo real com box de requisitos (mínimo 6 caracteres, letra maiúscula, letra minúscula, número e caractere especial) nas telas de cadastro e alteração de senha.
- Widget de botões reutilizáveis (`buttons_widget.dart`): `PrimaryButton`, `SecondaryButton`, `GhostButton` e `DarkButton`.
- Widget de loader animado (`loading_widget.dart`) com três pontos pulsantes baseado em `AnimationController`.
- Sistema centralizado de rotas nomeadas com `AppRoutes` e `buildRoutes()`.
- Navegação completa do fluxo de autenticação:
  - Splash → Welcome → Login
  - Login → Seleção de Cadastro → Cadastro
  - Login → Alteração de Senha → Login
- Formatadores de texto reutilizáveis: `UpperCaseTextFormatter` e `PhoneInputFormatter`.
- Paleta de cores definida em `AppColors` e `MeatShopColors`.

---

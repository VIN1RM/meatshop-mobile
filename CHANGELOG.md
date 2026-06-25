# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Projeto ainda não publicado]

---

## [2.11.0] - 2026-06-25
### Avaliações de Clientes no Detalhe do Açougue e do Produto

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

### Changed
- Botão "Ver todas" movido para inline com o título da seção via `Row + Expanded`, responsivo para qualquer largura de tela.
- Preview de reviews limitado a 3 itens na `ButcherDetailScreen`.
- `darkMode: false` aplicado aos cards na `UnitReviewsScreen` para manter fundo branco.
- Padding inferior da seção de reviews aumentado para 100px, evitando sobreposição com a sacola flutuante.
- `withOpacity` substituído por `withValues(alpha:)` nos widgets de reviews.
- Callbacks `errorBuilder` corrigidos de `(_, __, ___)` para `(_, __, _)`.

### Fixed
- `_reviews` e `_reviewService` não declarados no `State` da `ProductDetailScreen`.
- Card de empty state não centralizado horizontalmente (ausência de `width: double.infinity`).

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
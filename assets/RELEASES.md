# Notas de Lançamento (RELEASES)

Este arquivo contém o resumo de todas as novidades e melhorias do aplicativo, explicadas de forma simples para que você saiba exatamente o que mudou em cada atualização.

---

## [3.0.0] — Em desenvolvimento
### Uma Nova Base para o MeatShop

### ✨ Novidades
- **Entregador Autônomo ou da Unidade:** Quem se cadastra pelo app pode trabalhar como autônomo, enquanto contas criadas pelo açougue continuam sob aprovação da unidade.
- **Chat em Tempo Real:** Cliente, açougue e entregador conversam nos canais corretos de cada pedido, com mensagens não lidas, confirmação de leitura e indicação de digitação.
- **Atualizações ao Vivo:** Mudanças da entrega chegam imediatamente e o aplicativo recupera o estado correto depois de uma oscilação de internet.
- **Fotos do Veículo:** O entregador pode manter fotos reais do veículo no cadastro integrado.
- **Área do Entregador Integrada:** Cadastro, aprovação, veículos, disponibilidade, ofertas, entregas, histórico, avaliações, ganhos e metas agora podem acompanhar o sistema oficial do MeatShop.
- **Códigos Protegidos na Entrega:** O entregador apresenta o código de retirada à unidade e conclui a entrega somente com o código informado pelo cliente.
- **Mais Privacidade nas Ofertas:** O endereço exato do cliente só fica disponível depois que o entregador aceita a entrega.
- **Checkout Integrado:** Seus pedidos agora são criados no mesmo sistema usado pelo açougue, aparecendo no painel da unidade logo após a confirmação.
- **Pagamento por Carrinho:** Quando houver produtos de vários açougues, você realiza um único fluxo de pagamento e recebe pedidos separados e organizados.
- **Acompanhe e Repita:** Histórico, detalhes, cancelamento, agendamento e recompra passam a acompanhar o estado oficial do pedido.
- **Código de Entrega Protegido:** O código necessário para receber o pedido fica disponível somente para você enquanto ainda for válido.
- **Um Carrinho, Vários Açougues:** Você pode adicionar produtos de unidades diferentes no mesmo carrinho. Os itens ficam organizados por açougue e, no checkout, serão preparados como pedidos separados.
- **Perfil e Endereços Sincronizados:** Seus dados, foto e endereços agora podem acompanhar sua conta pelo sistema MeatShop, inclusive ao trocar de aparelho.
- **Endereço pelo CEP:** Informe o CEP para preencher rua, bairro, cidade e estado e localizar o endereço sem digitar coordenadas.
- **Marketplace Integrado:** Açougues, produtos, promoções, horários e avaliações agora podem ser carregados diretamente do sistema MeatShop.
- **Busca Unificada:** A busca encontra açougues, categorias e produtos em uma única consulta.
- **Login Conectado ao MeatShop:** O login por e-mail, Google ou Apple agora pode criar uma sessão segura no mesmo sistema usado pelo painel e pelo banco de dados principal.
- **Vínculo Protegido:** Quando já existir uma conta com o mesmo e-mail, a senha atual será solicitada uma única vez antes de vincular o login.
- **Integração em Andamento:** Começamos a evolução que conectará o aplicativo ao mesmo backend e banco de dados usados pelo painel do açougue.
- **Conexões Mais Confiáveis:** A nova base já diferencia falta de internet, demora do servidor, sessão expirada e cancelamento de uma operação.
- **Sessão Mais Segura:** As credenciais do aplicativo passam a ter armazenamento protegido pelo próprio Android ou iOS e renovação coordenada.

### 📈 Melhorias
- **Valores Conferidos no Servidor:** Preços, descontos, cupons e taxa de entrega são recalculados antes da confirmação.
- **Pedido sem Duplicidade:** Se a conexão oscilar durante a finalização, o sistema reconhece a tentativa anterior e evita cobrar ou criar o pedido novamente.
- **Estoque Consistente:** Produtos de diferentes açougues são reservados com segurança; uma falha não deixa apenas parte do carrinho confirmada.
- **Estoque e Preço Conferidos:** O sistema confere novamente disponibilidade, categoria, preço e quantidade sempre que o carrinho muda.
- **Produtos por Peso:** O carrinho aceita quantidades fracionadas com precisão adequada para carnes vendidas por quilo.
- **Limpeza Real do Carrinho:** Ao esvaziar a sacola, os itens também são removidos do servidor e não reaparecem em outro acesso.
- **Disponibilidade Confiável:** Produtos inativos, categorias inativas ou itens sem estoque deixam de ser oferecidos no novo catálogo.
- **Perfil Consistente:** Tipo de perfil e conclusão do cadastro passam a vir do sistema MeatShop durante o novo fluxo, evitando divergências entre aplicativo e painel.
- **Preparado para a Migração Gradual:** As próximas funcionalidades poderão ser transferidas uma por vez, sem trocar todos os fluxos de uma só vez.
- **Qualidade Automatizada:** Novos testes protegem a arquitetura e os comportamentos essenciais de conexão e sessão.

> A versão 3.0.0 permanece em desenvolvimento. Estas notas serão incrementadas a cada fase do plano de integração.

---

## [2.15.0] — 20 de Agosto de 2026
### 🔐 Login Mais Seguro e Cadastro sem Repetição

### ✨ Novidades
- **Uma Conta para Todos os Tipos de Login:** Se você já possui cadastro com e-mail e senha, agora pode vincular Google ou Apple à mesma conta. Na primeira vez, basta confirmar sua senha; depois, o login social entra diretamente na conta original.
- **Seus Dados Continuam no Lugar:** Ao vincular um login social, seu perfil, pedidos, endereços, veículo e preferências permanecem associados à conta que você já utilizava.
- **Complete Apenas o que Falta:** Nome, CPF, celular, tipo de perfil, endereço e veículo já cadastrados são reconhecidos automaticamente. A tela mostra somente as informações ainda pendentes.

### 📈 Melhorias
- **Conclusão Obrigatória do Cadastro:** Ao escolher completar o perfil, a tela permanece aberta até que todos os dados necessários sejam salvos. O aviso e a tela não podem mais ser fechados pelo botão ou gesto de voltar.
- **Perfil Cliente & Entregador Completo:** Quem utiliza os dois modos agora informa e mantém tanto o endereço de cliente quanto o veículo de entrega no mesmo cadastro.
- **Tentativas de Login Renovadas:** Tentativas incorretas antigas deixam de ficar acumuladas indefinidamente. Após 5 minutos sem novas falhas, o usuário volta a ter as cinco tentativas disponíveis.

### 🐞 Correções
- Corrigida a criação de contas duplicadas ao usar Google ou Apple com um e-mail já cadastrado.
- Corrigido o bloqueio imediato depois de uma única senha incorreta quando existiam falhas antigas salvas.
- Corrigida a solicitação de dados que o usuário já havia preenchido anteriormente.
- Corrigida a criação duplicada de endereço ou veículo ao finalizar um cadastro pendente.

---

## [2.14.0] — 21 de Julho de 2026
### 👋 Conheça o MeatShop Antes de Começar

### ✨ Novidades
- **Tour Rápido pelo App:** Na sua primeira vez no MeatShop, agora você vê um tour rápido explicando como escolher um açougue, montar seu pedido, agendar a entrega e acompanhar tudo em tempo real.
- **Só Aparece Uma Vez:** O tour é exibido automaticamente apenas no seu primeiro acesso — depois disso, você vai direto para a tela de login normalmente.
- **Pule Quando Quiser:** Se preferir não ver o tour, basta tocar em "Pular" a qualquer momento.

---

## [2.13.0] — 03 de Julho de 2026
### 🔐 Login com Google e Apple, Cadastro Mais Rápido

### ✨ Novidades
- **Login Mais Rápido:** Agora você pode entrar no MeatShop usando sua conta Google ou Apple.
- **Complete Seu Cadastro em Segundos:** Se for seu primeiro acesso com Google ou Apple, uma tela simples vai pedir só o essencial: nome, CPF, celular e, dependendo do seu perfil, endereço ou dados do veículo.
- **Escolha Como Quer Usar o App:** Na primeira vez, você escolhe se quer ser Cliente, Entregador, ou os dois ao mesmo tempo.
- **Evite Contas Duplicadas:** Se você tentar se cadastrar com um CPF, e-mail ou celular que já possui uma conta, o app agora avisa na hora e te ajuda a ir direto para o login — sem precisar preencher tudo de novo.
- **Continue de Onde Parou:** Se identificarmos que faltam informações no seu cadastro (nome, CPF, celular, endereço ou veículo), você verá um aviso convidando você a completar seus dados antes de continuar usando o app.

### 📈 Melhorias
- **Acesso Mais Seguro:** O login com Google e Apple usa verificação direta com essas plataformas, mantendo sua conta protegida.
- **E-mail Já Preenchido no Login:** Ao ser direcionado para o login por já ter uma conta cadastrada, seu e-mail já aparece preenchido — só falta digitar a senha.
- **Menos Digitação:** Ao completar seu cadastro, os dados que já temos sobre você (nome, CPF e celular) já vêm preenchidos automaticamente, já com a formatação correta — você só precisa confirmar e informar o que faltar.

---

## [2.12.0] — 27 de Junho de 2026
### 💬 Lista de Conversas Funcionando e Identificação Correta dos Participantes

### ✨ Novidades
- **Tela de Chat Carregando com Estilo:** Enquanto as conversas e os dados do entregador carregam, o app agora exibe uma animação suave de esqueleto no lugar de um simples círculo giratório, deixando a experiência mais agradável.

### 📈 Melhorias
- **Lista de Chats Agora Funciona de Verdade:** A tela de conversas passou a exibir corretamente todas as suas conversas, mesmo as iniciadas antes desta atualização.
- **Nome Certo na Lista de Chats:** O nome do entregador, do açougue ou do cliente agora aparece corretamente em cada conversa — antes aparecia "Usuário" para todo mundo.
- **Aba de Chats Renomeada:** O item "Chats com estabelecimentos" na tela de conta foi simplificado para "Chats", já que a lista exibe todos os tipos de conversa.
- **Conversa Criada Automaticamente:** Ao abrir um chat, o aplicativo agora garante que a conversa seja registrada corretamente no banco de dados com os dados dos dois participantes, evitando que ela fique invisível na lista depois.

### 🐞 Correções
- Corrigido problema em que a lista de chats ficava vazia mesmo com conversas existentes.
- Corrigido problema em que todos os participantes apareciam como "Usuário" na lista de conversas.
- Corrigido problema em que a conversa sumia da lista após ser iniciada pelo pedido.

---

## [2.11.0] — 25 de Junho de 2026
### 🛵 Conheça Seu Entregador e Avalie os Produtos

### ✨ Novidades
- **Avaliações do Açougue com Três Estados:** A seção de avaliações do açougue agora responde ao número de reviews disponíveis. Se não houver nenhuma, aparece um card com a mensagem "Seja o primeiro a avaliar". Se houver uma ou duas, os cards são exibidos com um banner incentivando mais avaliações. Com três ou mais, um botão "Ver todas" aparece ao lado do título e leva para a tela completa.
- **Avaliações do Produto:** A tela de detalhes do produto agora também exibe avaliações, com o mesmo comportamento de três estados da seção do açougue.
- **Tela Completa de Avaliações do Produto:** Nova tela dedicada para ver todas as avaliações de um produto, com cabeçalho e seta de voltar no padrão visual do aplicativo.
- **Visual Renovado dos Cards de Avaliação:** Os cards agora exibem avatar com as iniciais do cliente, estrelas maiores e mais elegantes, data ao lado do nome e visual limpo em fundo branco.
- **Veja Quem Vai Entregar o Seu Pedido:** Quando o seu pedido sair para entrega, um card aparece automaticamente com o nome e a foto do entregador, o tipo e modelo do veículo, a placa e uma foto do veículo. Toque na foto do entregador ou na foto do veículo para visualizá-las em tela cheia.
- **Avalie os Produtos Só Uma Vez:** O botão "Produtos" nos pedidos finalizados agora desaparece após o envio das avaliações, evitando avaliações duplicadas.

### 📈 Melhorias
- Botão "Ver todas" posicionado ao lado do título da seção, responsivo para qualquer tamanho de tela.
- A tela completa de avaliações do açougue agora segue o padrão visual da Home, com imagem de fundo e cabeçalho com seta de voltar.
- O conteúdo da tela do açougue agora rola até mostrar a última avaliação, sem ser coberto pela sacola flutuante.
- Divisores visuais adicionados entre as seções da tela do açougue para melhor organização.

---

## [2.10.0] — 22 de Junho de 2026
### ⭐ Avalie o Açougue, Veja as Estrelas e Encontre os Melhores Cortes

### ✨ Novidades
- **Avalie Sua Experiência:** Após a entrega do pedido, um botão "Avaliar" aparece no histórico. Ao tocar, você abre um fluxo dedicado para dar uma nota de 1 a 5 estrelas e deixar um comentário sobre o açougue e o entregador.
- **Dois em Um:** Quando há entregador no pedido, o fluxo passa por duas etapas — primeiro você avalia o açougue, depois o entregador. Um indicador de progresso mostra em qual etapa você está.
- **Foto Real de Quem Você Está Avaliando:** O cabeçalho de cada etapa exibe a foto real do açougue ou do entregador, deixando claro quem você está avaliando.
- **Avalie Só Uma Vez:** Cada pedido entregue pode ser avaliado apenas uma vez. Após o envio, o botão "Avaliar" desaparece automaticamente.

### 📈 Melhorias
- **Média de Estrelas Atualizada em Tempo Real:** As notas dadas pelos clientes são calculadas automaticamente e atualizam a avaliação média do açougue e do entregador logo após o envio.
- **Açougues Ordenados por Avaliação:** A lista de açougues agora exibe primeiro os estabelecimentos com maior nota média, tanto na tela inicial quanto na listagem completa.
- **Nota Exibida nos Cards:** Cada card de açougue agora mostra a nota real com uma estrela ao lado — ou um traço quando o açougue ainda não tem avaliações.
- **Filtro de Cortes Mais Intuitivo:** O ícone de filtro na tela de cortes agora muda de cor e exibe um ponto amarelo quando há algum filtro ativo, deixando mais fácil perceber que a lista está sendo filtrada.
- **Filtro de Cortes com Botão Limpar:** O painel de filtros de cortes ganhou um botão "Limpar" no rodapé, igual ao painel de açougues, facilitando remover os filtros de uma vez.
- **Mensagem de Lista Vazia Mais Clara:** Quando nenhum corte é encontrado com o filtro de preço aplicado, o app agora mostra uma mensagem específica com a opção de limpar os filtros diretamente na tela.

---

## [2.9.0] — 16 de Junho de 2026
### 🛒 Checkout Melhorado, Taxa de Entrega Correta e Acompanhamento de Pedidos

### ✨ Novidades
* **Taxa de entrega por açougue:** A tela de revisão do pedido agora calcula a taxa de entrega considerando a unidade/açougue responsável pelos produtos.
* **Botão de confirmação com carregamento:** Ao confirmar um pedido, o botão agora exibe estado de carregamento, evitando cliques repetidos enquanto a compra está sendo processada.
* **Data no acompanhamento do pedido:** A tela de acompanhamento agora exibe a data relacionada ao pedido, deixando o histórico mais claro para o usuário.
* **Mais status para pedido ativo:** O acompanhamento de pedidos ativos agora considera novos status, permitindo uma visualização mais completa do andamento da entrega.
* **Mensagem do usuário:** O fluxo de pedidos agora conta com suporte à mensagem enviada pelo usuário.
* **Base preparada para novas funções:** Foram criados utilitários internos para facilitar futuras funcionalidades e manter o código mais organizado.

### 📈 Melhorias
* **Criação de pedido mais precisa:** A taxa de entrega agora é definida corretamente no momento em que o pedido é criado.
* **Carrinho com dados completos:** Ao navegar a partir do carrinho, o aplicativo agora busca corretamente todas as informações do produto e da unidade/açougue.
* **Checkout mais confiável:** O fluxo de revisão e confirmação do pedido ficou mais consistente, principalmente em pedidos com taxa de entrega.

### 🐞 Correções
* Corrigido um problema em que a taxa de entrega não era aplicada corretamente na criação do pedido.
* Corrigido o cálculo da taxa de entrega na tela de revisão do checkout.
* Corrigido problema no fluxo de rejeição de pedidos.
* Corrigido o carregamento completo dos dados de produto e unidade ao abrir detalhes pelo carrinho.
* Corrigidos problemas no preenchimento automático por CEP e na seleção de endereço padrão.

---

## [2.8.0] — 12 de Junho de 2026
### 🍽️ Receitas, Carrinho Melhorado e Mais Segurança no Login

### ✨ Novidades
* **Nova área de receitas:** O aplicativo agora conta com uma área dedicada a dicas de receitas, carregadas diretamente do banco de dados.
* **Receitas em tempo real:** As dicas de receitas agora são sincronizadas com o Firestore, permitindo atualizar o conteúdo sem depender de dados fixos no app.
* **Tela de detalhes da receita:** Adicionamos uma tela dedicada para visualizar melhor as informações de cada receita.
* **Imagem do açougue no carrinho:** O carrinho agora exibe a imagem da unidade/açougue responsável pelos produtos.
* **Acesso ao produto pelo carrinho:** Agora é possível navegar para os detalhes do produto diretamente a partir do carrinho.
* **Bloqueio temporário de login:** Após múltiplas tentativas incorretas de login, o aplicativo bloqueia temporariamente novas tentativas para aumentar a segurança da conta.

### 📈 Melhorias
* **Visual das receitas aprimorado:** A tela de detalhes das receitas recebeu ajustes visuais para deixar a leitura mais agradável e organizada.
* **Perfil com foto atualizada:** A edição de perfil agora envia corretamente a foto atual do usuário para o seletor de avatar.
* **Tela de produto mais limpa:** A informação de marca foi removida da seção de detalhes do produto, deixando a interface mais objetiva.
* **Textos ajustados:** Alguns textos da interface foram revisados para melhorar a clareza.

### 🐞 Correções
* Corrigida a navegação para a tela de produto.
* Corrigida a exibição da imagem da unidade/açougue no carrinho.
* Ajustado o comportamento do login após tentativas falhas.

---

## [2.7.0] — 08 de Junho de 2026
### 🎨 Visual Unificado nos Menus e Melhor Adaptação a Telas Pequenas

### 📈 Melhorias
- **Visual Consistente em Todo o App:** Todos os menus e painéis que sobem pela parte de baixo da tela agora seguem o mesmo estilo claro e limpo do restante do aplicativo — fundo branco, textos escuros e bordas suaves.
- **Cancelamento de Pedido Atualizado:** O painel de cancelamento de pedido ganhou o novo visual claro, ficando mais legível e agradável.
- **Edição de Veículo Atualizada:** O painel de edição do veículo também foi atualizado para o novo padrão visual.
- **Seleção de Foto de Perfil Atualizada:** O menu de troca de foto de perfil acompanhou a padronização visual.
- **Filtros de Açougue e Cortes Atualizados:** Os painéis de filtro seguem agora o mesmo padrão dos demais menus do app.
- **Seleção de Destinatário no Chat Atualizada:** O painel que pergunta com quem você quer falar no chat também foi atualizado.
- **Detalhes de Entrega Atualizados:** O painel de detalhes de uma entrega concluída agora usa o mesmo estilo claro.
- **Formulário de Cartão Atualizado:** O painel de cadastro de cartão foi padronizado com o novo visual.
- **Menus Adaptados ao Teclado:** Ao abrir o teclado em qualquer um desses menus, o conteúdo se ajusta automaticamente para não ficar escondido atrás do teclado.
- **Suporte a Telas Menores:** Todos os menus agora scrollam corretamente em celulares com telas pequenas, sem cortar informações.
- **Notificações Padronizadas em Todo o App:** Todas as mensagens de feedback (sucesso, erro, aviso e informação) agora seguem o mesmo estilo visual em todas as telas do aplicativo.
- **Contador de Itens no Carrinho:** O ícone do carrinho na barra de navegação agora exibe um balãozinho vermelho com a quantidade de itens adicionados, facilitando saber o que está na sacola sem precisar abrir o carrinho.

### ✨ Novidades
- **Salvar Só Quando Mudar Algo:** Na tela de edição do veículo, o botão "Salvar alterações" só fica disponível quando você realmente fez alguma modificação — tipo, modelo, cor, ano, placa ou fotos.
- **Fechar Sem Salvar é Seguro:** Se você abrir a edição do veículo, fizer alterações e fechar sem salvar, o app descarta tudo automaticamente, sem nenhuma pergunta — como se você nunca tivesse mexido.
- **Sacola Rápida:** Agora, ao navegar pela tela de um produto ou de um açougue, um botão flutuante aparece automaticamente quando você tem itens no carrinho. Ao tocar nele, uma sacola abre mostrando tudo que você já adicionou — com quantidade, preço e total — sem precisar sair da tela onde está.

---

## [2.6.0] — 05 de Junho de 2026
### 🔔 Notificações, Ganhos em Tempo Real e Metas Conectadas ao Banco de Dados

### ✨ Novidades
- **Central de Notificações:** O aplicativo agora conta com uma estrutura própria para exibir e armazenar notificações do usuário.
- **Notificações de Pedido:** Agora o app identifica mudanças no status dos pedidos e exibe avisos para o usuário acompanhar melhor cada etapa.
- **Banner de Notificação em Primeiro Plano:** Quando o aplicativo está aberto, as notificações aparecem em um banner personalizado dentro do app, seguindo a identidade visual do MeatShop.
- **Histórico de Notificações:** As notificações recebidas são salvas no banco de dados e podem ser exibidas posteriormente na área de notificações.
- **Contador de Não Lidas:** O app agora consegue identificar e exibir a quantidade de notificações ainda não lidas.
- **Marcar como Lida:** O usuário pode marcar notificações individualmente como lidas.
- **Marcar Todas como Lidas:** Também foi adicionada a opção de marcar todas as notificações como lidas de uma só vez.
- **Token de Notificação:** O app agora salva automaticamente o token FCM do usuário no login, permitindo o envio de notificações push.
- **Preferências de Notificação que Funcionam de Verdade:** Agora os toggles de notificação na tela de Configurações realmente funcionam. Ao desativar um tipo (Pedidos, Entrega, Promoções ou Sistema), o app para de exibir aquele tipo de notificação — inclusive as de atualização de pedido em tempo real.
- **Configurações Salvas no Dispositivo:** As preferências do aplicativo agora são salvas localmente no seu celular e restauradas automaticamente sempre que você abrir o app.

### 📈 Melhorias
- **Experiência em Primeiro Plano:** As notificações recebidas com o app aberto agora usam um visual próprio, mais bonito e integrado ao aplicativo.
- **Navegação por Notificação:** Ao tocar em uma notificação de pedido, o app direciona o usuário para a área relacionada.
- **Canal Android Padronizado:** O canal de notificações do Android foi configurado para pedidos, entregas e promoções do MeatShop.
- **Tempo de Exibição Ajustado:** O banner de notificação em primeiro plano agora permanece visível por mais tempo, facilitando a leitura.
- **Ganhos Registrados Automaticamente:** Ao finalizar uma entrega, o valor é salvo automaticamente no histórico de ganhos do entregador, sem necessidade de nenhuma ação manual.
- **Metas e Ganhos em Tempo Real:** As informações da tela de Gestão, ganhos do dia, progresso das metas e gráfico semanal agora refletem dados reais do banco de dados, atualizados instantaneamente.

---

## [2.5.0] — 03 de Junho de 2026
### 💬 Chat em tempo real, Endereço do Açougue e Melhorias de Carregamento

### ✨ Novidades
- As conversas agora são salvas e sincronizadas em tempo real — suas mensagens aparecem instantaneamente para o outro lado.
- A lista de conversas mostra um badge com a quantidade de mensagens não lidas por conversa.
- As mensagens são agrupadas por data, facilitando a leitura do histórico.
- A tela rola automaticamente para a mensagem mais recente ao abrir uma conversa.
- O entregador agora pode iniciar conversa tanto com o açougue quanto com o cliente diretamente pela tela de entrega ativa.
- **Horários de Funcionamento do Açougue:** As informações de horário de funcionamento das unidades agora estão disponíveis no aplicativo.
- **Endereço Completo do Açougue:** A tela do açougue e os cards de pedido do entregador agora exibem o endereço completo da unidade — rua, número, bairro, cidade e estado.

### 🛵 Pedidos disponíveis em tempo real para o entregador
- A aba de entregas agora exibe os pedidos reais feitos pelos clientes, sem dados de exemplo.
- Os pedidos aparecem automaticamente assim que ficam disponíveis, sem precisar recarregar a tela.
- Cada card de pedido mostra o nome do cliente, nome do açougue, endereços de retirada e entrega, lista de itens e valor total — tudo buscado diretamente do banco de dados.
- Ao aceitar um pedido, o status é atualizado imediatamente para todos os envolvidos.
- Se o app for fechado durante uma entrega em andamento, o pedido ativo é restaurado automaticamente ao reabrir.
- Novo botão de atualização na aba de entregas — tanto na lista de pedidos quanto na tela vazia — com indicador de carregamento e confirmação de sucesso ou erro.

### 📈 Melhorias
- **Carregamento Antecipado das Telas:** A tela inicial, a tela do açougue e a tela do produto agora aguardam o carregamento completo dos dados antes de exibir o conteúdo, eliminando o flash de tela vazia.
- **Notas de Versão Mais Informativas:** O título de cada versão agora é exibido no dialog de novidades, lido diretamente do arquivo de releases sem nenhum dado fixo no código.
- **Dialog de Novidades Responsivo:** O dialog de notas de versão agora se adapta corretamente a qualquer tamanho de tela, sem quebrar o layout em celulares menores.

### 🐞 Correções
- Corrigido um problema no carregamento de promoções que podia causar erros ao exibir os dados.
- Corrigido a exibição do nome do estabelecimento na tela do carrinho.
- Corrigido um problema no chat que impedia a persistência correta das conversas ao reabrir o app.
- Corrigido erro de asserção `!_dirty` causado por `notifyListeners` chamado durante a construção da árvore de widgets na tela do açougue.
- Corrigido `LateInitializationError` no carregamento da tela inicial ao restaurar sessão.

---

## [2.4.0] — 01 de Junho de 2026
### 🔎 Pedidos e Acompanhamento em Tempo Real, Chat com o Açougue Certo

### ✨ Novidades
- **Busca Global no Aplicativo:** Agora o app conta com uma tela de busca global, permitindo pesquisar diferentes tipos de informações em um só lugar.
- **Pedidos Conectados ao Firestore:** A tela de pedidos agora carrega informações reais do Firebase Firestore, substituindo os dados simulados.
- **Endereços Dinâmicos no Agendamento:** A tela de endereço e agendamento agora exibe os endereços reais cadastrados pelo usuário no Firestore.
- **Adicionar Produto ao Carrinho:** Agora é possível adicionar produtos ao carrinho diretamente pela tela de detalhes do produto.
- **Botão de Voltar Reutilizável:** Foi criado um novo componente padrão de botão de voltar, deixando a navegação mais segura e consistente entre as telas.
- **Máscaras de Entrada Reutilizáveis:** Foram adicionadas máscaras em utilitários para padronizar campos de entrada e melhorar a experiência de preenchimento.
- **Pedidos em Tempo Real:** A tela de pedidos agora carrega diretamente do banco de dados, exibindo seus pedidos em andamento e finalizados dos últimos 3 meses sem nenhum dado simulado.
- **Acompanhamento de Entrega ao Vivo:** A tela de acompanhamento agora exibe seus pedidos ativos em tempo real, com o status atualizado automaticamente conforme o açougue processa o pedido.
- **Cancelar Pedido pelo App:** Agora você pode cancelar um pedido diretamente pela tela de acompanhamento, enquanto ele ainda estiver aguardando confirmação ou confirmado.
- **Contatar o Açougue Certo:** O botão "Contatar estabelecimento" na tela de acompanhamento agora leva você direto para a conversa com o açougue responsável pelo seu pedido. Se você tiver pedidos de mais de um açougue ao mesmo tempo, o app pergunta com qual deles você quer falar.
- **Carrinho Limpo Após o Pedido:** Ao confirmar um pedido com sucesso, o carrinho é esvaziado automaticamente, tanto no app quanto no banco de dados.

### 📈 Melhorias
- **Carrinho Mais Intuitivo:** Agora é possível tocar em um item do carrinho para editar o produto, além da inclusão de divisores visuais entre os itens.
- **Remoção de Itens com Confirmação:** O carrinho agora permite remover itens deslizando para o lado, com dialog de confirmação e mensagem de feedback.
- **Proteção ao Reduzir Quantidade:** Ao tentar diminuir a quantidade de um item para zero, o app solicita confirmação antes de remover o produto.
- **Chat com Visual Melhorado:** A barra de digitação do chat foi redesenhada e o layout da tela recebeu melhorias para ficar mais organizado.
- **Endereços com Interface Padronizada:** Os dialogs relacionados a endereços foram ajustados para seguir o mesmo padrão visual do aplicativo.
- **Definição de Endereço Padrão Melhorada:** Agora, ao definir um endereço como padrão, o app exibe confirmação e feedback visual para o usuário.
- **Edição de Endereço pelo Agendamento:** A bottom sheet de endereço de entrega agora permite atualizar os dados do endereço selecionado.
- **Tela de Alteração de Senha Padronizada:** O botão de voltar customizado foi substituído pelo cabeçalho padrão do app e pelo novo botão reutilizável.
- **Chat Mais Inteligente:** O chat agora identifica corretamente o açougue com quem você está conversando, independentemente de como a conversa foi iniciada.

### 🐞 Correções
- **Correção na Busca:** Corrigido um problema em que a busca podia tentar atualizar a interface durante o encerramento da tela.

---

## [2.3.0] — 30 de Maio de 2026
### 🛒 Carrinho Real, Açougues com Produtos e Promoções do Banco de Dados

### ✨ Novidades
- **Carrinho Conectado à Sua Conta:** O carrinho agora exibe os produtos reais que você adicionou, diretamente do banco de dados. Nada mais é simulado — tudo que aparece lá é o que você escolheu de verdade.
- **Produtos Reais no Açougue:** Ao entrar na página de um açougue, você agora vê os produtos reais cadastrados por ele, com foto, preço e unidade de medida vindos diretamente do sistema.
- **Promoções do Açougue em Destaque:** Caso o açougue tenha promoções ativas, elas aparecem em um carrossel especial no topo da página, com badge de desconto e acesso direto ao produto.
- **Nome do Açougue nos Cortes:** Na listagem de cortes, cada produto agora exibe o nome do açougue ao qual pertence, logo abaixo do nome do produto.

### 📈 Melhorias
- **Carrinho Organizado por Açougue:** Os itens do carrinho são agrupados automaticamente por estabelecimento, facilitando a visualização do que você vai pedir de cada lugar.
- **Remover Item do Carrinho:** Adicionamos um botão de remoção individual em cada item do carrinho, sem precisar zerar a quantidade.
- **Navegação pelo Carrossel de Promoções:** Tocar em uma promoção na tela inicial agora leva direto para a tela do produto com todos os detalhes corretos.
- **Foto e Localização do Açougue:** A tela de detalhes do açougue agora exibe a foto real, o nome e a cidade cadastrados no banco de dados.

---

## [2.2.0] — 28 de Maio de 2026
### 🎨 Visual Padronizado, Refatorações e Melhorias de UX

### ✨ Novidades
- **Termos de Uso:** Adicionamos um dialog de Termos de Uso na tela de configurações, com link direto para a página oficial.

### 📈 Melhorias
- **Tela de Pagamento Mais Consistente:** Os cards de método de pagamento e as abas da tela de pagamento foram padronizados visualmente, deixando tudo mais coeso e agradável.
- **Tela de Endereço e Agendamento Renovada:** A tela de seleção de endereço e agendamento recebeu um redesign para melhor organização e leitura.
- **Botões Mais Responsivos:** Os botões do app foram ajustados para se adaptar melhor a diferentes tamanhos de tela.
- **Fundo das Telas Unificado:** A cor de fundo foi padronizada globalmente em todas as telas do aplicativo.
- **Cards de Pedidos Padronizados:** Os cards da tela de pedidos do entregador agora seguem o mesmo padrão visual claro das demais telas.
- **Confirmação de Entrega Aprimorada:** O dialog de confirmação de entrega foi extraído como componente independente, tornando a tela de entrega ativa mais organizada.
- **Detalhes do Pedido Aprimorados:** O resumo de detalhes do pedido foi extraído como componente próprio, seguindo o padrão de organização do app.

---

## [2.1.0] — 27 de Maio de 2026
### 🥩 Açougues Reais, Sessão Persistente e Endereços Melhorados

### ✨ Novidades
- **Açougues Conectados ao Firestore:** A tela inicial e a lista de açougues agora exibem unidades reais cadastradas no banco de dados, removendo os dados simulados.
- **Sessão Mantida ao Reabrir o App:** Agora, ao fechar e abrir o aplicativo novamente, o usuário continua conectado e é direcionado automaticamente para a área correta.
- **Endereços Salvos do Cliente:** O gerenciamento de endereços agora está integrado ao Firestore, permitindo carregar, adicionar, editar, definir como padrão e remover endereços reais.
- **Busca Automática por CEP no Cadastro:** Ao informar um CEP válido durante o cadastro de cliente, o app preenche automaticamente rua, bairro, cidade e UF.
- **Confirmação de Remoção de Endereço:** A remoção de endereços salvos agora possui um componente próprio de confirmação.

### 📈 Melhorias
- **Cadastro de Cliente Mais Rápido:** O formulário de cadastro ficou mais prático, preenchendo automaticamente os dados do endereço a partir do CEP informado.
- **Fluxo de Endereços Mais Seguro:** O app agora aguarda a conclusão das operações de criação e edição de endereço antes de fechar o formulário.
- **Cards Mais Consistentes:** As telas de carrinho, pedidos, dicas de receitas e endereços salvos receberam padronização visual nos cards.
- **Carregamento Padronizado:** A lista de açougues agora usa o carregamento padrão do aplicativo.
- **Fundo das Telas Padronizado:** Ajustamos a cor de fundo das telas para manter a consistência visual da aplicação.

---

## [2.0.0] — 18 de Maio de 2026
### 🔐 Login Real, Conta Conectada e Fotos de Verdade

### ✨ Novidades
- **Login e Cadastro de Verdade:** O aplicativo agora usa autenticação real. Seus dados são verificados com segurança e a sua conta é criada diretamente no nosso sistema — nada mais é simulado.
- **Excluir Conta com Segurança:** Adicionamos um fluxo para exclusão definitiva da conta. Por segurança, você precisa confirmar a sua senha antes de prosseguir.
- **Alteração de Senha Protegida:** Para trocar a senha, o app agora pede que você confirme a senha atual antes de aceitar a nova. Assim, só você pode fazer essa mudança.

### 📈 Melhorias
- **Seus Dados São Seus:** As informações exibidas na tela de perfil (nome, e-mail, celular) agora vêm diretamente da sua conta real, sempre atualizadas.
- **Fotos no Lugar Certo:** As fotos de perfil e as fotos do veículo (para entregadores) agora são armazenadas de forma adequada, deixando o app mais rápido e eficiente.
- **Celular Salvo no Cadastro:** Corrigimos um problema em que o número de celular não era salvo corretamente durante o cadastro em alguns tipos de conta.
- **Formulário de Endereço Corrigido:** Ajustamos um erro visual na tela de cadastro que causava campos sobrepostos ou duplicados na seção de endereço.

---

## [1.6.0] — 04 de Maio de 2026
### ✨ Novidades
- Escolha o Endereço Antes de Pagar: Adicionamos uma nova tela entre o carrinho e o pagamento onde você seleciona para qual endereço quer receber o pedido. Seus endereços salvos aparecem logo de cara para facilitar.
- Peça Agora ou Agende: Na mesma tela de endereço, você pode escolher receber o pedido o quanto antes ou agendar para um dia e horário específico. Basta tocar na aba "Agendar" escolher a data no calendário e selecionar a faixa de horário preferida.
- Resumo Antes de Confirmar: Agora, antes de tudo ser finalizado, você passa por uma tela de resumo completo do pedido — itens, endereço, taxas e total — para ter certeza de que está tudo certo antes de confirmar.
- Carrossel de Promoções Ampliado: A seção de promoções na tela inicial agora exibe mais produtos, passando automaticamente de um para o outro de forma contínua e infinita.
- Acesse o Produto Direto pelo Carrossel: Tocar em qualquer card de promoção na tela inicial leva você direto para a tela de detalhes daquele produto.
- Foi adicionado um novo assistente virtual, para auxiliar em ideias de cortes, receitas, temperos e muito mais.
- Peça a Quantidade Certa: Na tela do produto, agora você escolhe exatamente quanto quer pedir — em gramas ou quilos. Digite o valor que quiser ou use os atalhos rápidos. O total é calculado na hora conforme você ajusta.
- Pedir Novamente com Um Toque: Nos pedidos já finalizados, aparece o botão "Pedir novamente". Ao tocar, o app mostra um resumo do pedido anterior: itens, quantidades e valor total, e te leva direto para a tela de endereço para confirmar.

### 📈 Melhorias
- Fluxo de Compra Reorganizado: A ordem das etapas de finalização foi ajustada para ser mais natural — agora você define o endereço e o horário antes de escolher o pagamento, e revisa tudo no final antes de confirmar.
- Navegação entre Produtos Sugeridos: Ao tocar em um produto sugerido na tela de detalhes, o app abre diretamente aquele produto sem acumular telas desnecessárias.

---

## [1.5.0] — 30 de Abril de 2026
### ✨ Novidades
- Pagamento Completo no App: Criamos uma tela dedicada para escolher como pagar o seu pedido, com duas opções claras — pagar agora pelo app ou pagar na hora da entrega. Tudo num só lugar, antes de confirmar.
- Pague Online com Pix ou Cartão: Na aba "Pagar online" você pode escolher Pix (com QR Code gerado automaticamente após confirmar), cartão de crédito (com opção de parcelamento) ou cartão de débito. Seus cartões salvos aparecem logo de cara para facilitar.
- Pague na Entrega do Jeito que Preferir: Na aba "Na entrega" você escolhe entre dinheiro (com opção de informar o troco necessário), débito ou crédito na maquininha. Ao escolher cartão, basta indicar a bandeira (Visa, Mastercard, Elo e outras).
- Confirmação de Compra Animada: Após confirmar o pedido, uma tela especial mostra o progresso da sua compra em tempo real — do registro ao processamento do pagamento — e celebra quando tudo dá certo antes de levar você direto para o acompanhamento.
- Edição de Dados Pessoais: Agora você pode editar suas informações diretamente pelo app. Acesse "Editar dados" na tela da sua conta e atualize nome, e-mail, celular e endereço quando quiser. O CPF é exibido apenas para consulta e não pode ser alterado por aqui.
- Troca de Foto de Perfil: Toque na sua foto de perfil na tela de edição e escolha entre tirar uma nova foto na hora ou selecionar uma imagem da sua galeria. Caso já tenha uma foto cadastrada, também é possível removê-la diretamente pela mesma tela.

### 📈 Melhorias
- Visual Mais Consistente: Padronizamos o cabeçalho e o fundo visual em todas as telas do aplicativo, deixando a experiência mais coesa e profissional do início ao fim.
- Gestão Pessoal para Entregadores: Os entregadores agora têm acesso a uma tela exclusiva com acompanhamento de ganhos em tempo real, metas diárias, semanais e mensais com barras de progresso, e relatórios exportáveis em PDF ou CSV.

---

## [1.4.0] — 26 de Abril de 2026
### ✨ Novidades
- Modo Duplo para Usuários Especiais: Se a sua conta tiver os dois perfis (Cliente e Entregador), agora ao entrar no app você verá uma tela elegante para escolher como quer usar o MeatShop naquele momento. Basta tocar na opção desejada e aguardar!
- Conta do Entregador: Nova tela de perfil exclusiva para entregadores, com estatísticas de entregas realizadas, avaliação média e acesso rápido às configurações do veículo.
- Troca de Modo Facilitada: Após escolher, o app memoriza o seu perfil ativo durante a sessão. Você pode alternar quando quiser pelas configurações.
- Cadastro de Veículo para Entregadores: Agora você pode adicionar ou editar o seu veículo diretamente pelo app. Escolha o tipo (Carro, Moto, etc...), preencha os dados e adicione até 3 fotos do veículo.
- Seleção de Foto Facilitada: Na hora de adicionar as fotos do veículo, você pode escolher entre tirar uma foto na hora ou selecionar uma já existente da sua galeria.
- Chat Durante a Entrega: Agora o entregador pode conversar diretamente com o açougue ou com o cliente durante uma entrega ativa. Basta tocar em "Falar com..." na tela de entrega e escolher com quem deseja falar.
- Tela de Troca de Modo: Ao alternar entre o modo Cliente e o modo Entregador, o app exibe uma tela de transição com uma animação suave e uma mensagem personalizada enquanto prepara o ambiente para você.
- Recusa de Pedido com Motivo: O entregador agora pode recusar um pedido selecionando um ou mais motivos (distância, veículo, área de risco, entre outros) antes de confirmar a recusa.

---

## [1.3.0] — 22 de Abril de 2026
### ✨ Novidades
- Cadastro de Endereço Inteligente: Agora, ao digitar o seu CEP, o aplicativo preenche automaticamente a rua, o bairro e a cidade para você. Mais rápido e sem erros de digitação!
- Nova Tela de Configurações: Um lugar centralizado para você gerenciar a sua conta, notificações e consultar informações sobre o aplicativo.
- Pagamento com Cartão Facilitado: Adicionamos uma nova forma de cadastrar os seus cartões de crédito diretamente na hora de finalizar o pedido, com um visual mais moderno e seguro.

### 📈 Melhorias
- Visual do Chat: As telas de conversa com os estabelecimentos ficaram mais bonitas e confortáveis para leitura, utilizando o novo tema escuro.
- Ajustes de Ecrã: O formulário de endereços agora adapta-se melhor a telemóveis com ecrãs menores, garantindo que nada fique "cortado".
- Visual de Abertura e Login Renovado: A tela de carregamento e a tela de login ganharam um novo visual, com a logo atualizada e uma imagem de fundo sutil que deixa o app mais elegante desde o primeiro segundo.

---

## [1.2.0] — 15 de Abril de 2026
### ✨ Novidades
- Chat com o Açougue: Agora você pode conversar diretamente com o estabelecimento para tirar dúvidas sobre o seu pedido.
- Acompanhamento de Entrega: Adicionamos uma tela para você saber exatamente em que pé está o seu pedido.
- Detalhes do Produto: Agora, ao clicar em um item, você vê fotos maiores, descrição detalhada e sugestões de outros produtos que combinam com a sua compra.

### 📈 Melhorias
- Sem "Telas Travadas": Adicionamos indicadores de carregamento (bolinhas a pulsar) em várias partes do app para você saber que o sistema está a processar a sua solicitação.

---

## [1.1.0] — 09 de Abril de 2026
### ✨ Novidades
- Filtros Avançados: Agora você pode ordenar os açougues por nome, melhor avaliação ou pelos mais baratos.
- Categorias de Carnes: Criamos telas específicas para cortes Bovinos, Suínos, Aves e Peixes, facilitando encontrar exatamente o que procura.
- Busca Unificada: Adicionamos uma barra de pesquisa em todas as telas principais para você encontrar cortes ou lojas rapidamente.

### 📈 Melhorias
- Segurança no Login: Melhoramos o sistema que mantém você conectado, garantindo que a sua sessão seja segura e o encerramento da conta (sair) funcione perfeitamente.

---

## [1.0.0] — 11 de Março de 2026
### 🚀 O Nascimento do MeatShop!
- Primeira Versão: Lançamento oficial do aplicativo com todas as funções básicas para começar.
- Cadastro Personalizado: Criamos fluxos diferentes para quem quer comprar (Cliente) e para quem quer trabalhar connosco (Estafeta).
- Segurança da Senha: O sistema agora ajuda você a criar uma senha forte, mostrando em tempo real se ela cumpre os requisitos de segurança.
- Visual Moderno: Interface limpa, com animações de abertura e botões fáceis de clicar.

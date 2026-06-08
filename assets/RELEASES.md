# Notas de Lançamento (RELEASES)

Este arquivo contém o resumo de todas as novidades e melhorias do aplicativo, explicadas de forma simples para que você saiba exatamente o que mudou em cada atualização.

---

## [2.7.0] — 08 de Junho de 2026
###

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
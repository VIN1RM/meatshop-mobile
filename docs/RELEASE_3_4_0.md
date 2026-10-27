# Preparação da versão 3.4.0+2

Data de preparação: 26 de outubro de 2026.

## Escopo

- Retirada no balcão por unidade, sem endereço nem taxa, concluída com o código do cliente.
- Filtro de marca combinado com nome, categoria e faixa de preço nas telas de cortes e do açougue.
- Histórico de pedidos completo e paginado.
- Quantidades limitadas ao estoque real informado pela API.
- Contato opcional nos chamados de suporte.
- Contagem regressiva do bloqueio de login com o prazo informado pelo servidor.
- Consentimento de analytics controlado pelo usuário.
- Ganhos do entregador atualizados por evento em tempo real.
- Permissão de notificações solicitada de forma contextual.
- Streaming das respostas do assistente de receitas.
- Mensagens de erro sem detalhes técnicos.

## Compatibilidade

Esta versão deve ser disponibilizada junto ao backend e ao painel web 3.4.0 e ao chatbot 3.1.0. O backend precisa estar com as migrations da versão 3.4.0 aplicadas, pois o aplicativo depende da retirada no balcão, do contato no suporte, do prazo de bloqueio e do evento de ganhos.

## Validação antes de publicação

- Executar análise estática e a suíte completa de testes Flutter.
- Validar retirada no balcão, histórico paginado, filtro de marca, bloqueio de login, ganhos e assistente em emulador ou dispositivo com a API de homologação.
- Conferir o código de build já distribuído nas lojas antes de publicar; `+2` é o identificador preparado localmente.

Esta preparação não publica builds nas lojas.

# Revisão do mobile — 28 de outubro de 2026

## Interface

Configurações contém a seção Suporte e dados, com divisor entre os atalhos. A exportação apresenta JSON, Excel e PDF apenas como formatos futuros: não consulta a API de exportação, não gera arquivos e não compartilha dados.

As telas de chamados usam cabeçalho, cores, campos e botões do aplicativo, preservam o texto quando o envio falha e se adaptam ao teclado. Os diálogos de busca por cidade e código do cliente compartilham uma superfície responsiva. O código exige seis números antes de confirmar.

Veículos exibem Moto, Carro e Bicicleta, com cartões espaçados e indicação correta do veículo principal. As fotos da unidade incluem logo, capa e `gallery_urls`; as fotos do produto são consultadas em `GET /products/:id`, incluindo `images`. O visualizador permite deslizar entre fotos, ampliar e tentar novamente após falha de consulta.

## Notificações

As quatro preferências são persistidas por usuário em `notification_preferences`, pela API `/notifications/preferences`. O mobile mantém a última cópia sincronizada para leitura offline e reverte alterações quando o salvamento falha.

| Tipo | Quando é criado |
| --- | --- |
| Pedidos (`ORDER`) | Novo pedido para a equipe, mudanças de status, confirmação de pagamento e mensagens do chat do pedido. |
| Entregas (`DELIVERY`) | Eventos de retirada, atribuição de entregador e disponibilidade dos códigos protegidos. Os códigos não são expostos no push. |
| Promoções (`PROMOTION`) | Ativação/início de campanha vigente para clientes ativos que já concluíram uma compra na unidade e permitem promoções. A verificação das campanhas agendadas ocorre a cada minuto; a campanha é reivindicada atomicamente para evitar duplicação. |
| Sistema (`SYSTEM`) | Eventos de suporte e avisos administrativos explícitos. Não há aviso automático só por abrir o aplicativo. |

O envio push respeita a preferência de cada tipo e depende de token FCM válido, permissão do aparelho e credenciais do Firebase Admin. Desativar o push não apaga o histórico. Pedidos, entregas e sistema ainda podem gerar registros no aplicativo; promoções também filtram os destinatários antes de criar o aviso. No ambiente local revisado, a conta de serviço do Firebase Admin não está configurada; o recebimento efetivo de push não foi certificado.

## Avaliações e preço

`reviews` armazena avaliações de unidades e produtos. A nota da unidade é a média simples das avaliações com `product_id IS NULL`, arredondada para uma casa decimal. As avaliações de produtos não entram nessa nota. Sem avaliações, a API retorna zero.

`delivery_reviews` armazena avaliações dos entregadores, com uma avaliação por pedido. Após avaliar, o backend recalcula a média simples e atualiza `delivery_persons.average_rating`. Somente o cliente do pedido pode avaliar, após a entrega, com nota de 1 a 5.

A ordenação por preço anteriormente não alterava a lista. Agora o backend informa `average_price_per_kg`: média simples dos preços de catálogo dos produtos ativos, em categorias ativas e com estoque positivo. Produtos em gramas são convertidos para reais por kg; produtos por unidade, litro ou outras medidas são excluídos. Promoções e taxa de entrega não entram nessa referência. Esse indicador compara catálogos diferentes; não representa o preço de uma cesta idêntica.

O mobile carrega todas as páginas da região antes de ordenar e mantém unidades sem preço comparável no final, tanto no menor quanto no maior preço. Não há alterações de schema para essa referência calculada.

## Codificação

Os textos corrompidos identificados na conta sintética foram corrigidos diretamente nos respectivos registros locais. Não foi adicionado um decodificador genérico à interface, evitando alterar nomes válidos.

## Validação executada

- 287 testes Flutter aprovados e análise estática sem pendências.
- 26 testes de notificações e unidades aprovados no backend.
- Teste de preços em PostgreSQL real, em esquema isolado e transação revertida, aprovado.
- Persistência das quatro preferências conferida pela API local; valores originais restaurados.
- Backend reconstruído e saudável, com o novo indicador de preço conferido na API pública.

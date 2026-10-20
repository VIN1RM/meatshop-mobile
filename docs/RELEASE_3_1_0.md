# Aceite da versão 3.1.0

A validação automatizada não substitui o aceite em Android e iOS com os serviços publicados.

| Fluxo | Verificação manual |
|---|---|
| Cadastro | Criar cliente e entregador, verificar e-mail, fechar app e confirmar que os dados e fotos são retomados |
| Sessão | Abrir sem rede, tentar novamente e invalidar refresh token durante uso |
| Identidade | Alterar e verificar e-mail; excluir conta com senha, Google e Apple |
| Catálogo | Comprar KG, G, UN e PCT, editar na sacola e no carrinho |
| Agendamento | Unidade fechada, horários distintos e data sem expediente em comum |
| Pagamentos | Dois vendedores, retorno externo, recusa, expiração e reconciliação |
| Entrega | Aceitar, reiniciar app, gerar código de retirada e confirmar no painel |
| Conclusão | Cliente consulta código, renova e informa somente após receber |
| Notificações | App encerrado, sessão expirada, pedido finalizado e perfil entregador |
| Relatórios | Concluir entrega, registrar repasse no painel e atualizar ganhos/metas |
| Falhas | Busca, endereço, receitas, avaliações, chat e veículos sem rede |
| Layout | 320 px, fonte ampliada, teclado aberto e navegação de retorno |

## Compatibilidade com o backend

Publique as alterações do backend junto com o aplicativo 3.1.0. A exclusão de contas Firebase passa a exigir o token de uma confirmação recente da identidade no cabeçalho `x-firebase-reauth-token`; clientes anteriores precisam ser atualizados para esse fluxo. A confirmação pertence ao mesmo usuário e expira em cinco minutos.

A API aceita bicicleta e patinete sem placa, mantém placa obrigatória para carro e moto, recusa quantidades fracionadas de UN/PCT e valida o expediente em America/Sao_Paulo. Estas mudanças não criam migrações de banco.

O rascunho de cadastro é protegido no dispositivo, separado por identidade, removido após a conclusão e expira em sete dias. As fotos interrompidas são retomadas sem recriar o veículo ou reenviar as fotos já confirmadas.

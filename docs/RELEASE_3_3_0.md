# Preparação da versão 3.3.0+1

Data de preparação: 20 de outubro de 2026.

## Escopo

- Busca com categoria, marca, preço mínimo e preço máximo combináveis.
- Agendamento consultado na API, respeitando horários, duração e capacidade configurados por todas as unidades do carrinho.
- Preferências de notificações persistidas no backend e aplicadas ao push de pedidos, entregas, promoções e mensagens do sistema.
- Registro do token FCM condicionado à autorização efetiva do sistema operacional.

## Compatibilidade

Esta versão deve ser disponibilizada junto ao backend e ao painel web 3.3.0. Antes da validação, executar as migrations de preferências de notificações e configuração de capacidade de agendamento.

## Validação antes de publicação

- Executar análise estática e a suíte completa de testes Flutter.
- Validar busca combinada, carrinho com uma e várias unidades e esgotamento do último horário.
- Confirmar preferências de push após sair e entrar novamente na conta.
- Conferir o código de build já distribuído nas lojas antes de publicar; `+1` é o identificador preparado localmente.

Esta preparação não publica builds nas lojas.

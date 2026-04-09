# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Projeto ainda não publicado]

## [1.1.0] - 2026-04-09

### Added

- Tela de listagem de acougues (`acougues_screen.dart`) com ordenacao por nome, avaliacao e faixa de preco via bottom sheet de filtro (`butcher_filter_sheet.dart`).
- Tela de cortes bovinos (`bovine_cuts_screen.dart`) com listagem, busca em tempo real e filtro por ordem e faixa de preco.
- Tela de cortes suinos (`swine_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Tela de cortes de aves (`poultry_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Tela de cortes de peixe (`fish_corts_screen.dart`) com mesma estrutura de busca e filtro dos cortes bovinos.
- Widget de filtro reutilizavel para cortes (`cuts_filter_sheet.dart`) com suporte a ordenacao e faixa de preco, compartilhado entre todas as telas de cortes.
- Widget de busca reutilizavel (`search_widget.dart`) com suporte a hint text configuravel, botao de voltar opcional, callbacks `onChanged` e `onSubmitted`, e botao de limpar integrado.
- Tela de acompanhamento de entrega (`deliveries_screen.dart`) alinhada ao design do Figma
- `AppShell` com `BottomNavigationBar` compartilhado entre as telas principais.

### Changed

- `SearchWidget` substituiu as implementacoes duplicadas de search bar em todas as telas: `HomePage`, `AcouguesScreen`, `BovineCortsScreen`, `FishCortsScreen`, `PoultryCortsScreen`, `SwineCortsScreen` e `DeliveriesScreen`.
- `CartScreen` refatorada com remocao da search bar e centralizacao dos chips de metodo de pagamento.
- Indice de tab do `AppShell` corrigido para refletir a aba ativa corretamente em todas as rotas.

---

## [1.0.0] - 2026-03-11

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
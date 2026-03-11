# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Projeto ainda não publicado]

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
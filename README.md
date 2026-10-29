# 🥩 MeatShop - Mobile

> Conectando clientes, açougues e entregadores em uma plataforma prática e segura.

**Versão:** 3.4.0+2 (em desenvolvimento)

**Última atualização do desenvolvimento:** 28 de outubro de 2026

**Autor:** Vinícius Rodrigues

**Plataforma:** Android & iOS

**Status:** Em desenvolvimento 🚧

---

## 📖 Sobre o Projeto

O **MeatShop** nasceu de uma necessidade real: facilitar a compra de carnes frescas e cortes especiais diretamente de açougues locais, sem filas, sem deslocamento e com rastreamento do pedido em tempo real.

Mais do que um app de compras, o MeatShop é uma **plataforma completa de três pontas**: o cliente faz o pedido, o açougue prepara e o entregador leva até a porta, tudo dentro de um único sistema integrado.

O projeto resolve um problema que afeta milhões de consumidores brasileiros: a falta de digitalização dos açougues locais e a dificuldade em conectar esses estabelecimentos a clientes e entregadores de forma eficiente.

---

## 🎯 Problema que Resolvemos

Açougues tradicionais geralmente não possuem presença digital. O cliente precisa se deslocar, não consegue visualizar os cortes disponíveis com antecedência e muitas vezes encontra o produto que queria esgotado. Do outro lado, os entregadores independentes não têm uma plataforma dedicada ao segmento de carnes e alimentos frescos.

O MeatShop resolve isso ao digitalizar toda a cadeia:

- **Clientes** encontram açougues próximos, visualizam o cardápio, fazem pedidos e acompanham a entrega em tempo real.
- **Açougues** gerenciam seu estoque, recebem pedidos e controlam o fluxo de entregas pelo web e possuem as informações refletidas no app.
- **Entregadores** recebem chamadas de entrega, gerenciam suas rotas e acompanham seus ganhos.

---

## 👥 Público-Alvo

| Perfil | Descrição |
|--------|-----------|
| 🛒 **Consumidor Final** | Pessoas que compram carne regularmente e buscam praticidade, qualidade e entrega rápida em casa |
| 🏪 **Açougues e Frigoríficos** | Estabelecimentos que querem digitalizar suas vendas e alcançar mais clientes sem depender de marketplaces genéricos |
| 🛵 **Entregadores Autônomos** | Profissionais de entrega que buscam uma plataforma especializada com demanda constante |

---

## 🛠️ Tecnologias Utilizadas

### Mobile
| Tecnologia | Uso |
|------------|-----|
| **Flutter** | Framework principal para desenvolvimento mobile multiplataforma |
| **Dart** | Linguagem de programação |

### Arquitetura e Padrões
| Padrão | Descrição |
|--------|-----------|
| **Clean Architecture em camadas** | Separação do projeto em `core`, `data`, `infra`, `models`, `providers`, `services` e `ui` |
| **Widgets reutilizáveis** | Componentes compartilhados entre telas |
| **Responsive layout** | Tamanhos e espaçamentos relativos ao tamanho da tela via `MediaQuery` |

## Refatoração de integração

O aplicativo está integrado ao backend NestJS por REST e Socket.IO, com PostgreSQL como fonte dos dados de negócio. O desenvolvimento atual acontece na branch `develop`. O Firebase permanece responsável pela identidade e pelos serviços complementares do mobile.

- [Roadmap completo](MOBILE_BACKEND_INTEGRATION_ROADMAP.md)
- [Decisões e contratos da integração](docs/backend-integration/README.md)
- [Preparação completa do ambiente](SETUP.md)
- [Evidências da Fase 10](docs/backend-integration/PHASE_10_QUALITY_SECURITY_COMPLETION.md)


## Jornada automatizada com backend local

Execute `./scripts/run-local-integration.ps1 -Flutter C:/flutter/bin/flutter.bat` no PowerShell, com o Docker Desktop e um emulador Android disponíveis. O script também requer Node.js e Firebase CLI instalados. Use `-Device` para selecionar outro emulador e `-BackendRoot` se o repositório web/backend não estiver na pasta irmã `meatshop`.

O executor cria um projeto Docker temporário com rede e volumes próprios, API na porta 3101 e Firebase Authentication Emulator na porta 9099. A consulta de CEP usa uma resposta sintética em um serviço interno, sem depender de provedores externos. Ele gera contas, senha, unidade, estoque e endereço sintéticos; nenhuma credencial de produção é necessária. As portas 3101 e 9099 precisam estar livres. O backend deve conter o suporte ao Firebase Auth Emulator no login por senha em desenvolvimento.

A jornada usa os serviços e repositórios reais do mobile para cadastrar e verificar e-mail, autenticar, renovar sessão, comprar, consultar chat, retirar e entregar o pedido por código e registrar o recebimento em dinheiro. Ela confere o estado final do pedido e os históricos de cliente e entregador na API com PostgreSQL. Não realiza cobranças no Mercado Pago. Os testes de widgets continuam responsáveis pela interação e apresentação das telas.

Os contêineres e volumes temporários são removidos ao terminar. Os logs ficam na pasta temporária informada pelo executor. Use `-KeepEnvironment` para inspecionar os dados após a execução; nesse caso, o executor informa a pasta que contém o Compose para encerrar esse ambiente. O aplicativo de integração é instalado no dispositivo escolhido; depois, inicie o aplicativo normalmente com a configuração local de desenvolvimento.


## Validação de campos e qualidade

As validações compartilhadas ficam em `lib/core/utils/field_validations.dart`: CPF e CNPJ numérico, e-mail, celular brasileiro e normalização de DDI, CEP, UF, textos obrigatórios e limites, senhas, placas, ano de veículo, valores monetários e códigos de entrega. Os formulários usam esse módulo, que reaproveita a política de senha de `PasswordPolicy`. A validação de login preserva a compatibilidade com senhas existentes; as regras de negócio e a autorização continuam no backend.

Na atualização de 28 de outubro de 2026, a suíte do mobile passou com 269 testes, a análise estática e a formatação foram aprovadas e o aplicativo foi compilado e aberto no emulador Android. A jornada de integração local também foi validada com API e PostgreSQL reais, autenticação emulada e pagamento em dinheiro.

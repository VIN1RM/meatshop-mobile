# 🥩 MeatShop - Mobile

> Conectando clientes, açougues e entregadores em uma plataforma prática e segura.

**Versão:** 1.2.0  
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

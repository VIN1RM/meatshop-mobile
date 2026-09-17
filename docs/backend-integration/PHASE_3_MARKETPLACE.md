# Fase 3 — Marketplace e consultas públicas

## Regra de publicação

Toda unidade criada no PostgreSQL aparece imediatamente no marketplace. Não existe aprovação, moderação ou estado de publicação para unidades. Filtros geográficos apenas restringem resultados quando `lat` e `lng` são enviados juntos; unidades sem coordenadas continuam aparecendo nas consultas sem localização.

## Contratos públicos

- `GET /units?page=&limit=&lat=&lng=&radius_km=`: unidades públicas, distância opcional e avaliação derivada das avaliações PostgreSQL;
- `GET /units/:id`: detalhe público sem CNPJ ou identificador do administrador;
- `GET /units/:unitId/business-hours`: horários de funcionamento;
- `GET /categories?unit_id=&active=true`: categorias ativas;
- `GET /products?unit_id=&category_id=&available=true&page=&limit=`: somente produto e categoria ativos com estoque positivo;
- `GET /promotions?marketplace=true&unit_id=&page=&limit=`: somente promoções ativas, vigentes e ligadas a produto vendável;
- `GET /reviews?marketplace=true&unit_id=&product_id=&page=&limit=`: leitura paginada de avaliações;
- `GET /search?q=&unit_id=&category_id=&min_price=&max_price=&page=&limit=`: busca combinada de unidades, categorias ativas e produtos vendáveis.

Os parâmetros `available=true` e `marketplace=true` preservam os contratos administrativos existentes do painel.

## Mobile e corte gradual

`MarketplaceRepository` é o contrato único usado pelo novo fluxo. A implementação HTTP traduz IDs numéricos, decimais PostgreSQL, paginação e respostas agrupadas para os modelos atuais da apresentação.

Com `FEATURE_BACKEND_MARKETPLACE=true`, unidades, categorias, produtos, promoções, horários, busca e leitura de avaliações usam a API. Com a flag desligada, os serviços legados mantêm o fallback Firestore. A UI e os Providers não conhecem cliente HTTP nem tokens.

As escritas de avaliações continuam no fluxo legado até a migração de pedidos e avaliações autenticadas; a Fase 3 altera somente consultas públicas.

## Validação

- testes backend cobrem publicação imediata, combinação obrigatória de coordenadas e raio/distância;
- testes mobile cobrem acesso público sem sessão, parsing e solicitação explícita de produtos vendáveis;
- a linha de base arquitetural removeu `ProductProvider` da lista de consumidores Firestore;
- backend: 12 suítes e 38 testes aprovados, além de lint dos arquivos alterados, typecheck e build;
- mobile: 25 testes aprovados, analyzer da infraestrutura e Providers migrados sem ocorrências, build Web e APK debug gerados com autenticação e marketplace backend ativos.

Os gates globais legados registrados nas fases anteriores permanecem separados do escopo desta fase.

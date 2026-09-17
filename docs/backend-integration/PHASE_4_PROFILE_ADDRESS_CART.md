# Fase 4 — Perfil, endereços, mídia e carrinho

## Resultado

Perfil, avatar, endereços e carrinho podem usar exclusivamente o backend NestJS e o PostgreSQL quando `FEATURE_BACKEND_PROFILE_CART=true`. Providers dependem de contratos em `lib/data`; HTTP, sessão e parsing permanecem em `lib/infra`.

O Firestore continua disponível somente como fallback temporário enquanto a flag estiver desligada. Não há escrita dupla.

## Ativação local

Ative as fases anteriores junto da Fase 4:

```bash
flutter run \
  --dart-define=MEATSHOP_API_URL=http://10.0.2.2:3001 \
  --dart-define=MEATSHOP_ENV=development \
  --dart-define=FEATURE_BACKEND_AUTH=true \
  --dart-define=FEATURE_BACKEND_MARKETPLACE=true \
  --dart-define=FEATURE_BACKEND_PROFILE_CART=true
```

Em dispositivo físico, substitua `10.0.2.2` pelo IP local da máquina que executa a API.

## Contratos integrados

- `GET/PATCH /users/me` para perfil;
- `POST/DELETE /users/me/avatar` para imagem multipart;
- `GET/POST/PATCH/DELETE /addresses` e seleção de padrão;
- `POST /geocoding/resolve` para endereço e coordenadas pelo CEP;
- `GET /cart`, `POST /cart/items`, `PATCH/DELETE /cart/items/:itemId` e `DELETE /cart`.

## Decisão do carrinho multiunidade

Um único carrinho aceita produtos de vários açougues. A resposta da API contém a lista completa e grupos por `unit_id`, com subtotal de cada unidade e total geral. Não existe bloqueio ou substituição do carrinho ao trocar de unidade.

Na Fase 5, o checkout consumirá esses grupos e criará um pedido independente por unidade dentro de uma única experiência de compra. Estoque, preço, categoria e atividade são revalidados pelo backend a cada inclusão ou alteração.

Quantidades aceitam até três casas decimais para produtos vendidos por peso. O mobile nunca decide disponibilidade ou preço oficial.

## Endereços e geocodificação

O usuário informa CEP e número, sem editar latitude/longitude. A API consulta o provedor configurado, normaliza CEP/cidade/UF e persiste as coordenadas. Rua e bairro resolvidos são usados quando o provedor os disponibiliza.

Endereços vinculados ao histórico de pedidos não são apagados; a API responde conflito com o código estável `ADDRESS_IN_USE`. Ao excluir o endereço padrão livre, o endereço restante mais antigo é promovido.

## Mídia

Avatar é enviado por `multipart/form-data`, limitado a 2 MB e aos formatos PNG, JPEG, WebP e GIF. O banco armazena apenas a URL relativa; o aplicativo resolve a URL completa usando a configuração do ambiente.

## Validação automatizada

- testes backend para quantidade fracionada, estoque, categoria inativa e agrupamento multiunidade;
- testes mobile dos contratos de perfil, CEP e carrinho autenticado;
- teste do Provider garantindo duas unidades no mesmo carrinho e limpeza remota;
- guardrails impedindo novos acessos diretos de UI/Providers à infraestrutura e novos imports Firestore.

Evidências de 2 de setembro de 2026:

- backend: 14 suítes e 42 testes unitários aprovados, typecheck, build Docker e lint estrito dos arquivos da fase;
- mobile: 30 testes aprovados, analyzer do núcleo novo da fase sem ocorrências, APK debug e build Web gerados com as Fases 1–4 ativas;
- Docker: PostgreSQL, backend e painel web saudáveis; migration aplicada em banco real;
- smoke test: autenticação, perfil, geocodificação real, CRUD de endereço e carrinho com duas unidades aprovados.

O lint completo do backend ainda acusa dívida de formatação anterior à fase; o conjunto backend alterado passa com zero avisos. O núcleo novo do mobile está limpo, enquanto telas tocadas pontualmente e o restante do projeto mantêm avisos legados registrados na linha de base de qualidade.

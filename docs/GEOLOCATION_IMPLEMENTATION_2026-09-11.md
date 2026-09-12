**Geolocalização — implementação e homologação**

Trabalho nas branches `develop`, sem commit. Este documento acompanha a auditoria de 11/09/2026. Implementação local não equivale à homologação de aparelhos ou de produção.

**Correspondência com a auditoria**

| Achados | Alteração |
| --- | --- |
| 1, 10, 14 | Transação com bloqueio do pedido; cancelamento, atribuição, consentimento e estado do entregador verificados no envio; encerramento remoto também reconciliado pelo mobile. |
| 2, 3 | Política específica de tracking para HTTP/socket; conta ativa, vínculo e expiração revalidados; socket expirado desconectado mesmo ocioso. |
| 4 | Coordenadas e endereço removidos dos payloads de auditoria; localização não gera uma cópia por amostra. Migração limpa cópias antigas dentro de transação e restaura a proteção contra alterações. |
| 5, 6 | Tela de acompanhamento do cliente com consulta inicial, socket e recuperação HTTP; mapa web com destinos, unidade e entregadores. |
| 7–9 | Serviço de localização Android com notificação, configuração iOS, recuperação de GPS/permissão, estado visível e controles de iniciar/pausar por entrega. Ao reabrir, requer nova escolha explícita. |
| 11–13 | Precisão sem restrição artificial de casas decimais; captura, identificadores de amostra/sessão, ordenação, amostras antigas e saltos; envios serializados e sinal periódico de 10 segundos. |
| 15–18 | Consulta de CEP unificada no backend; coordenadas opcionais para cadastro; correções manuais preservadas; pino confirmado, invalidação ao alterar endereço e proteção contra respostas antigas. O cadastro inicial direciona o endereço para o formulário após confirmação do e-mail. |
| 19 | Snapshot do destino no pedido. Editar endereço salvo não muda uma compra existente. |
| 20 | Checkout exige pinos confirmados; raio de entrega configurável por unidade; busca por endereço padrão do cliente; filtro e paginação no banco. |
| 21, 22 | Reconciliação temporal de socket/HTTP, descarte de resposta de outra unidade, assinatura confirmada, marcadores reaproveitados, acompanhamento opcional, erro/repetição de carregamento e provedor configurável. |
| 23 | Aviso com retenção configurada, registro de escolha, pausa e exclusão de posições, revogação no logout/indisponibilidade, encerramento e exclusão de conta. |
| 24 | Testes de contrato, política, GPS, reconciliação, banco real, migração com registros antigos e interface de seleção do pino. |

**Contrato e decisões operacionais**

- CEP fornece uma região aproximada; somente a confirmação do mapa produz `USER_PIN`. É uma indicação do usuário, não uma certificação cadastral do imóvel.
- Endereços existentes continuam cadastrados. Para nova entrega, cliente e unidade devem confirmar seus pinos. Retirada continua disponível sem coordenadas.
- Área atendida inicial: 25 km por unidade, editável no painel de 0,1 a 500 km. Frete e raio usam distância em linha reta; não representam distância viária nem ETA.
- Emissor envia no máximo uma amostra a cada 10 s; backend exige intervalo mínimo de 5 s. Precisão máxima aceita: 150 m; idade máxima no servidor: 60 s; tolerância de relógio futuro: 10 s. A interface mostra a precisão recebida.
- A sessão de compartilhamento é específica do pedido. Pausa com conexão revoga a sessão e apaga suas posições; falha de rede interrompe imediatamente o emissor e agenda nova tentativa de revogação enquanto o app estiver ativo. Reabrir a entrega reconcilia a sessão antiga antes de pedir novo consentimento.
- Retenção técnica mantém o parâmetro existente `DELIVERY_TRACKING_RETENTION_DAYS` (padrão 30). A limpeza roda na inicialização e diariamente às 03h de São Paulo. O aviso consulta o valor real via `/delivery/tracking-policy`. A escolha desse prazo e sua justificativa precisam constar da política adotada pelo controlador.
- A exclusão da conta elimina tracking relacionado e limpa snapshots de destino. Snapshots de endereço de pedidos de contas ativas seguem a finalidade do histórico de pedidos, separada das amostras do entregador.
- Métricas: `delivery_tracking_samples_total`, `delivery_tracking_capture_age_seconds`, `delivery_tracking_purged_total`; sem usuário, pedido ou coordenadas nos rótulos. A idade medida vai da captura ao backend; não mede o tempo de renderização no aparelho.

**Configuração dos mapas e publicação**

No painel: `NEXT_PUBLIC_MAP_STYLE_URL` ou `NEXT_PUBLIC_MAP_TILE_URL`. No Flutter: `--dart-define=MAP_TILE_URL=...`. Sem configuração, usam tiles públicos OSM. Produção com volume exige provedor com capacidade/termos apropriados; o fallback público não oferece garantia operacional de disponibilidade. Não fazer pré-carga ou download offline em massa desses tiles.

O backend continua com o adapter Socket.IO em memória: executar uma instância para entrega em tempo real. Aumentar réplicas exige adapter compartilhado e teste de eventos entre instâncias; o polling recupera estado, mas não torna o socket distribuído.

O novo contrato de GPS exige aplicativo atualizado. Planejar publicação coordenada de backend, painel e mobile; versões antigas deixam de enviar posições. A migração precisa de transação e permissão de proprietário da tabela de auditoria. A redação de payloads antigos é intencionalmente irreversível; o rollback estrutural não restaura esses dados.

Backups anteriores à migração ainda podem conter coordenadas. Mantê-los com acesso restrito, prazo documentado e descarte conforme a política; antes de tornar uma restauração disponível, reaplicar a limpeza e a retenção. O código não modifica backups gerenciados pelo provedor.

**Homologação que exige ambiente externo**

**Validações locais executadas:** 113 testes unitários do backend, 8 testes de integração PostgreSQL/HTTP/migração, 7 testes do painel, 57 testes do mobile e 2 testes adicionais de formulário. Teste Cypress aprovado no Chrome para CEP → mapa → confirmação → invalidação do pino. Análise Flutter sem ocorrências; lint do backend aprovado; builds Docker e APK Android debug gerados. Banco local migrado após backup, com frontend, backend e PostgreSQL saudáveis. As duas branches `develop` foram comparadas novamente com `origin/develop`: sem divergência de commits; alterações permanecem locais.

Backup local anterior à migração: `C:/Users/CLIENT/AppData/Local/Temp/meatshop-before-geolocation-20260911.dump`. Esse arquivo não pertence ao Git. O banco isolado dos testes chama-se `meatshop_geo_test`; os testes removem suas entidades de negócio ao terminar.

Para repetir a integração neste ambiente, no diretório `meatshop-backend`: definir `$env:GEO_TEST_DATABASE='meatshop_geo_test'` e executar `npm.cmd run test:e2e -- geolocation --silent`. O teste fixa conexão local e só é habilitado com esse nome de banco. No painel: `npm.cmd exec cypress run -- --headless --browser chrome --config-file cypress.geo.config.cjs`; no terminal do VS Code, remover `Env:ELECTRON_RUN_AS_NODE` somente desse processo caso o Electron inicie incorretamente. No mobile: `flutter test --no-pub --concurrency=1` e `flutter analyze --no-pub`. Não executar build e testes Flutter simultaneamente nesta estação.

Não há Android/iOS físico conectado nesta estação. Validar com cliente, unidade e entregador simultâneos:

1. CEP com/sem coordenadas, falha do provedor, alteração rápida de CEP, edição de número e confirmação do pino.
2. Movimento e parada, GPS aproximado, permissão negada/definitiva, GPS desligado, tela bloqueada e Maps/Waze.
3. Modo avião e reconexão, pausa sem rede, reinício, logout, cancelamento, reatribuição, revogação de vínculo e expiração da sessão.
4. Android e iOS físicos, incluindo restrições de bateria. Encerramento forçado pelo usuário não tem garantia de continuidade.
5. Na Vercel/Render: HTTPS, URLs permitidas em `CORS_ORIGINS`/`FRONTEND_URL`, cookies, autenticação do socket, reconexão e cold start com as novas versões. Nenhum resultado local certifica esse deploy.
6. Capacidade esperada de entregadores, latência captura→mapa, consumo de bateria/dados, crescimento do banco e execução da retenção.

Vercel/Render não foram publicados por este trabalho. Nenhum commit foi criado. A conformidade jurídica depende também das finalidades, bases, avisos, contratos, atendimento de direitos e políticas de backup da operação; este trabalho cobre controles técnicos, não uma certificação LGPD.

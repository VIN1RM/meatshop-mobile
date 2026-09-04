# Ambientes, reset e dados de desenvolvimento

## Ambientes

### Local

- backend e PostgreSQL executados pelo `docker-compose.yml` do repositório web/backend;
- Swagger em `http://localhost:3001/docs`;
- aplicativo executado pelo Flutter com a URL adequada ao dispositivo;
- Firebase deve usar projeto exclusivo de desenvolvimento.

### Homologação

- infraestrutura e banco separados de produção;
- projeto Firebase ou, no mínimo, configuração e contas claramente separadas;
- chaves sandbox do Mercado Pago;
- dados sintéticos, nunca cópia indiscriminada de produção.

### Produção

- HTTPS, banco gerenciado, secrets externos e backups;
- projeto Firebase de produção;
- Mercado Pago de produção somente após homologação;
- observabilidade e política de retenção/LGPD ativas.

## Inicialização local

No repositório que contém `docker-compose.yml`:

```powershell
docker compose up -d --build
docker compose ps
```

Resultado esperado:

- PostgreSQL saudável;
- migrator finalizado com código 0;
- backend saudável em `:3001`;
- frontend saudável em `:3000`.

Exemplo de execução do mobile no emulador Android após o corte definitivo:

```powershell
flutter run --dart-define=MEATSHOP_API_URL=http://10.0.2.2:3001 --dart-define=MEATSHOP_ENV=development
```

Para desktop ou Web, use `http://localhost:3001`; em dispositivo físico, use o IP local da máquina. Homologação e produção aceitam apenas HTTPS. A aplicação não assume uma URL padrão quando a fundação do backend é ativada.

## Reset do PostgreSQL local

> Destrutivo: execute somente no Compose local e depois de confirmar o diretório e o projeto Docker (`name: meatshop`).

```powershell
.\scripts\reset-development.ps1 -ConfirmProject meatshop
```

O script interrompe o stack, valida e remove somente o volume `meatshop_pgdata`, reconstrói as imagens, executa todas as migrations, aplica o seed e sobe backend e frontend. O seed recusa `NODE_ENV=production` e só executa com `SEED_ENABLED=true`.

## Dataset mínimo esperado

O seed é idempotente e contém apenas dados sintéticos:

- uma unidade ativa com endereço, coordenadas e horários;
- um proprietário/administrador da unidade;
- ao menos duas categorias;
- produtos ativos, inativos, com estoque e sem estoque;
- uma promoção e um cupom válidos, além de exemplos expirados;
- cliente Firebase vinculado a usuário PostgreSQL;
- entregador pendente e entregador aprovado com veículo ativo;
- endereços de cliente;
- cupom vigente `DEV10` e cenário expirado `EXPIRADO10`.

Todas as contas locais usam, exclusivamente em desenvolvimento, a senha `MeatshopDev123!`: `admin@meatshop.local`, `owner@meatshop.local`, `client@meatshop.local`, `delivery@meatshop.local` e `delivery.pending@meatshop.local`. Para federar uma conta Firebase preservada, informe seu UID na variável `SEED_*_FIREBASE_UID` correspondente antes do reset; sem UID, o primeiro vínculo por e-mail exige a senha local.

Credenciais de demonstração não devem ser reutilizadas em homologação ou produção.

## Limpeza do Firestore de desenvolvimento

Antes de apagar:

1. confirmar o projeto Firebase selecionado;
2. confirmar que ele é de desenvolvimento;
3. confirmar que não há dados reais;
4. registrar a operação na tarefa da Fase 9.

Opção pelo Firebase CLI, executada conscientemente por um responsável autenticado:

```powershell
firebase use <PROJECT_ID_DE_DESENVOLVIMENTO>
firebase firestore:delete --all-collections --force --project <PROJECT_ID_DE_DESENVOLVIMENTO>
```

Também é possível excluir coleções pelo Console Firebase. A exclusão de documentos Firestore não remove usuários do Firebase Authentication.

## Usuários Firebase

As contas do Firebase Authentication foram preservadas. A limpeza atingiu somente as coleções do Firestore no projeto de desenvolvimento `meatshop-3c78f`.

Não é necessário exportar senhas ou migrar hashes porque Firebase Auth continuará sendo o provedor de identidade do mobile.

As regras versionadas em `firestore.rules` negam toda leitura e escrita. Para reaplicar conscientemente no projeto de desenvolvimento:

```powershell
firebase deploy --only firestore:rules --project meatshop-3c78f
```

## Verificação pós-reset

- `GET /health` responde com sucesso;
- migrations executaram sem `synchronize`;
- Swagger está disponível no ambiente local;
- usuário Firebase consegue trocar ID Token por sessão MeatShop;
- painel web e mobile consultam a mesma unidade e catálogo;
- nenhuma coleção operacional Firestore reaparece durante as jornadas;
- pedidos criados no mobile aparecem no painel web;
- logs não contêm tokens, senhas, códigos completos ou dados de cartão.

## Produção

Os comandos destrutivos deste documento são exclusivos de desenvolvimento. Reset de homologação ou produção exige janela, backup, aprovação explícita, plano de rollback e identificação exata dos recursos.

# Fase 9 — Reset, seed e corte definitivo do Firestore

## Resultado

Em 3 de setembro de 2026 o PostgreSQL local foi recriado do zero, as 46 migrations foram executadas e o seed sintético foi aplicado duas vezes sem duplicar registros. Backend e painel responderam HTTP 200 após o processo.

O projeto Firebase de desenvolvimento `meatshop-3c78f` teve todas as coleções operacionais removidas. Usuários do Firebase Authentication foram preservados. As regras `firestore.rules` publicadas negam toda leitura e escrita, impedindo a recriação de documentos.

## Preparação reproduzível

No repositório web/backend:

```powershell
.\scripts\reset-development.ps1 -ConfirmProject meatshop
```

O parâmetro obrigatório, o nome fixo do projeto Compose e a validação do rótulo de `meatshop_pgdata` reduzem o risco de apagar outro banco. O script não remove volumes de uploads, logs ou observabilidade.

## Dataset

- uma unidade pública com coordenadas e sete registros de horário;
- proprietário e administrador vinculados à unidade;
- cliente com endereço padrão;
- entregadores aprovado e pendente, ambos com veículo sintético;
- duas categorias e quatro produtos, incluindo ativo, inativo, disponível e sem estoque;
- promoção vigente e cupons válido/expirado.

As contas e a senha exclusiva de desenvolvimento estão documentadas em `ENVIRONMENTS_AND_RESET.md`. UIDs preservados podem ser associados por variáveis `SEED_*_FIREBASE_UID`; o fluxo normal também permite primeiro vínculo por e-mail e senha.

## Corte do aplicativo

`FeatureFlags.fromEnvironment()` ativa permanentemente todos os repositórios backend já migrados. Defines antigos não reativam o fallback. O seed Firestore foi excluído. Adaptadores legados ainda presentes no código-fonte ficam inacessíveis à composição de produção e serão removidos fisicamente, junto com a dependência `cloud_firestore`, na Fase 10.

Firebase permanece somente para Authentication, FCM, App Check, Crashlytics, Analytics e Performance.

## Evidências

- migrations: 46;
- usuários PostgreSQL: 5;
- unidades: 1;
- categorias: 2;
- produtos/estoques: 4/4;
- vínculos de unidade: 2;
- entregadores: 2;
- seed executado novamente sem alterar essas cardinalidades;
- `GET /health`: HTTP 200;
- painel local: HTTP 200;
- regras Firestore compiladas e publicadas.

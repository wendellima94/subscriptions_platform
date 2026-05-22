# Plataforma de Assinaturas

Aplicação web para gerenciamento de planos, assinaturas e cobranças recorrentes.

O projeto foi desenvolvido em Ruby on Rails e implementa um fluxo completo de assinatura: catálogo de planos, ativação, cancelamento, geração de invoices, pagamento manual, área administrativa, área do cliente e API autenticada por token.

## Stack

- Ruby 4.0.0
- Rails 8.1.3
- SQLite
- Tailwind CSS
- RSpec
- Active Job
- `has_secure_password`
- GitHub Actions

## Funcionalidades

### Cliente

- Login e logout
- Visualização de planos ativos
- Ativação de assinatura
- Restrição de uma assinatura ativa por usuário
- Visualização da assinatura atual
- Cancelamento da assinatura
- Visualização de invoices
- Geração manual da próxima invoice
- Pagamento manual de invoices
- Bloqueio de pagamento fora da ordem cronológica

### Admin

- CRUD de planos
- Inativação de planos
- Bloqueio de remoção de planos com assinaturas vinculadas
- Listagem de assinaturas
- Filtro de assinaturas por status
- Listagem de invoices
- Filtro de invoices por status
- Filtro de invoices por mês de referência

### API

A API usa autenticação simples por token.

Endpoints disponíveis:

```text
GET  /api/v1/plans
POST /api/v1/subscriptions
GET  /api/v1/me/subscription
POST /api/v1/invoices/:id/pay
```

## Regras de negócio

### Planos

Um plano pode ter periodicidade:

```text
monthly
quarterly
```

O preço é armazenado em centavos no campo `price_cents`.

Exemplo:

```text
5990 = R$ 59,90
```

Apenas planos ativos podem ser assinados.

Planos com assinaturas vinculadas não podem ser removidos. Essa decisão preserva o histórico de assinaturas e invoices. Caso o plano não deva mais ser vendido, o admin deve inativá-lo.

### Assinaturas

Uma assinatura pode ter os seguintes status:

```text
pending
active
canceled
```

Ao ativar uma assinatura:

- a assinatura é criada como `active`
- `started_at` recebe a data/hora atual
- a primeira invoice é criada para o mês atual
- o vencimento da primeira invoice é em 5 dias
- o usuário não pode ter mais de uma assinatura ativa
- planos inativos não podem ser assinados

Ao cancelar uma assinatura:

- o status muda para `canceled`
- `canceled_at` recebe a data/hora atual
- a assinatura deixa de receber novas invoices mensais

### Invoices

Uma invoice pode ter os seguintes status:

```text
open
paid
expired
```

Ao gerar uma invoice:

- `reference_month` representa o mês de referência da cobrança
- `amount_cents` recebe o preço do plano no momento da geração
- `due_on` recebe a data de vencimento

O valor da invoice é salvo no momento da geração para preservar histórico financeiro caso o preço do plano seja alterado depois.

Ao pagar uma invoice:

- o status muda para `paid`
- `paid_at` recebe a data/hora atual
- invoices abertas mais antigas precisam ser pagas antes das futuras

Essa regra existe no domínio da aplicação, não apenas na interface. Assim, web e API respeitam o mesmo comportamento.

## Decisões técnicas

### Services para regras de domínio

As principais regras de negócio foram extraídas para services:

```text
Subscriptions::Activate
Subscriptions::Cancel
Invoices::GenerateForSubscription
Invoices::GenerateNextForSubscription
Invoices::Pay
Billing::GenerateMonthlyInvoices
```

Isso mantém controllers mais simples e centraliza regras importantes em objetos reutilizáveis.

### Idempotência na geração de invoices

A geração de invoices evita duplicidade para a mesma assinatura e mês de referência.

Isso permite chamar o job mensal ou o service mais de uma vez sem gerar cobranças duplicadas.

### Histórico financeiro preservado

O valor da invoice é salvo em `amount_cents` no momento da geração.

Mesmo que o preço do plano mude depois, invoices antigas continuam com o valor correto.

### SQLite

O projeto usa SQLite para facilitar execução local e avaliação.

A estrutura da aplicação foi mantida simples e pode ser adaptada para PostgreSQL sem mudança nas regras de domínio.

## Instalação

Clone o repositório:

```bash
git clone https://github.com/wendellima94/subscriptions_platform.git
cd subscriptions_platform
```

Instale as dependências:

```bash
bundle install
```

Prepare o banco de dados:

```bash
rails db:setup
```

Esse comando cria o banco, executa as migrations e roda os seeds.

Se preferir executar separadamente:

```bash
rails db:create
rails db:migrate
rails db:seed
```

## Rodando em desenvolvimento

Use:

```bash
bin/dev
```

Esse comando inicia dois processos definidos em `Procfile.dev`:

```text
web: servidor Rails
css: watcher do Tailwind CSS
```

A aplicação ficará disponível em:

```text
http://localhost:3000
```

Caso queira subir apenas o servidor Rails, sem o watcher do Tailwind:

```bash
rails server
```

## Credenciais de teste

Após rodar os seeds, use:

### Admin

```text
E-mail: admin@example.com
Senha: password123
```

### Customer

```text
E-mail: customer@example.com
Senha: password123
```

### Segundo customer

```text
E-mail: customer2@example.com
Senha: password123
```

## Dados criados no seed

O seed cria:

```text
1 admin
2 customers
3 planos
assinaturas de exemplo
invoices de exemplo
```

Os dados permitem testar rapidamente os fluxos de cliente e admin.

## Rotas web principais

### Autenticação

```text
GET    /login
POST   /login
DELETE /logout
```

### Cliente

```text
GET    /plans
POST   /subscriptions
GET    /subscription
DELETE /subscription
POST   /subscription/generate_next_invoice
POST   /invoices/:id/pay
```

### Admin

```text
GET    /admin/plans
GET    /admin/plans/new
POST   /admin/plans
GET    /admin/plans/:id/edit
PATCH  /admin/plans/:id
DELETE /admin/plans/:id

GET    /admin/subscriptions
GET    /admin/subscriptions?status=active
GET    /admin/subscriptions?status=canceled
GET    /admin/subscriptions?status=pending

GET    /admin/invoices
GET    /admin/invoices?status=open
GET    /admin/invoices?status=paid
GET    /admin/invoices?reference_month=2026-05
GET    /admin/invoices?status=open&reference_month=2026-05
```

## API

A API usa o header:

```text
Authorization: Bearer <api_token>
```

O token é gerado automaticamente para cada usuário.

Para consultar um token no console Rails:

```bash
rails console
```

```ruby
User.find_by(email: "customer@example.com").api_token
```

Substitua `TOKEN_DO_USUARIO` nos exemplos abaixo pelo token retornado no console.

### GET /api/v1/plans

Lista planos ativos.

```bash
curl http://localhost:3000/api/v1/plans
```

### POST /api/v1/subscriptions

Cria uma assinatura para o usuário autenticado.

Substitua `1` pelo ID de um plano ativo existente.

```bash
curl -X POST http://localhost:3000/api/v1/subscriptions \
  -H "Authorization: Bearer TOKEN_DO_USUARIO" \
  -H "Content-Type: application/json" \
  -d '{"plan_id": 1}'
```

### GET /api/v1/me/subscription

Retorna a assinatura ativa do usuário autenticado.

```bash
curl http://localhost:3000/api/v1/me/subscription \
  -H "Authorization: Bearer TOKEN_DO_USUARIO"
```

### POST /api/v1/invoices/:id/pay

Paga uma invoice pertencente ao usuário autenticado.

Substitua `1` pelo ID de uma invoice do usuário autenticado.

```bash
curl -X POST http://localhost:3000/api/v1/invoices/1/pay \
  -H "Authorization: Bearer TOKEN_DO_USUARIO"
```

A API não permite que um usuário acesse ou pague invoices de outro usuário.

Também não permite pagar uma invoice futura caso existam invoices abertas anteriores.

## Job mensal de invoices

O projeto possui o job:

```ruby
GenerateMonthlyInvoicesJob
```

Ele chama o service:

```ruby
Billing::GenerateMonthlyInvoices
```

Esse service gera invoices para assinaturas ativas.

Exemplo pelo console:

```bash
rails console
```

```ruby
GenerateMonthlyInvoicesJob.perform_now(Date.new(2026, 6, 1))
```

Também é possível chamar diretamente:

```ruby
Billing::GenerateMonthlyInvoices.call(reference_date: Date.new(2026, 6, 1))
```

A geração é idempotente: não cria invoice duplicada para a mesma assinatura e mês de referência.

## Testes

Rodar todos os testes:

```bash
bundle exec rspec
```

Rodar grupos específicos:

```bash
bundle exec rspec spec/models
bundle exec rspec spec/services
bundle exec rspec spec/requests
```

A suíte cobre:

```text
model validations
regras de assinatura
geração de invoices
pagamento em ordem
bloqueio de plano inativo
permissões básicas de web
endpoints da API
fluxos administrativos
```

Resultado atual:

```text
62 examples, 0 failures
```

## CI

O projeto possui GitHub Actions configurado em:

```text
.github/workflows/ci.yml
```

O workflow executa:

```text
bundle install
rails db:test:prepare
bundle exec rspec
```

A suíte automatizada roda a cada push para `main` ou `master` e em pull requests.

## Estrutura principal

```text
app/models
app/services
app/jobs
app/controllers
app/controllers/api/v1
app/controllers/admin
app/views
spec/models
spec/services
spec/requests
```

## Validação manual sugerida

### Cliente

1. Acessar `/login`
2. Entrar com `customer@example.com`
3. Acessar planos
4. Ativar assinatura
5. Ver assinatura atual
6. Gerar próxima invoice
7. Pagar invoice aberta mais antiga
8. Cancelar assinatura

### Admin

1. Entrar com `admin@example.com`
2. Criar, editar e inativar planos
3. Tentar remover plano com assinatura vinculada
4. Listar assinaturas
5. Filtrar assinaturas por status
6. Listar invoices
7. Filtrar invoices por status e mês

## Observações

- A autenticação web foi implementada de forma simples com sessão e `has_secure_password`.
- A API usa token por usuário via header `Authorization`.
- O foco do projeto está nas regras de domínio, organização do código, testes e fluxo funcional.
- O banco SQLite foi mantido para facilitar execução local durante a avaliação.
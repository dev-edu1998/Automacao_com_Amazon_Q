# 🚀 Deploy Automatizado na AWS com Amazon Q

<p align="left">
  <img src="https://img.shields.io/badge/AWS-ECS%20%7C%20ECR%20%7C%20ALB%20%7C%20RDS-FF9900?style=flat&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-22--slim-339933?style=flat&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/React-Vite-61DAFB?style=flat&logo=react&logoColor=black" />
  <img src="https://img.shields.io/badge/Docker-ECR-2496ED?style=flat&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/CI%2FCD-CodePipeline%20%7C%20CodeBuild-232F3E?style=flat&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Amazon%20Q-ECS%20MCP%20Server-8A2BE2?style=flat&logo=amazonaws&logoColor=white" />
</p>

Projeto desenvolvido durante o evento **AWS & IA** do professor Henrylle Maia, com foco na criação de ambientes na AWS utilizando **linguagem natural via Amazon Q Developer**.

A aplicação **BIA** é provisionada, construída e entregue automaticamente a cada push no GitHub — sem intervenção manual — graças a um pipeline completo de CI/CD integrado ao ECS, ECR, ALB e RDS.

> 🎓 **Projeto educacional:** a arquitetura prioriza **simplicidade e clareza** para facilitar o aprendizado. Os recursos são provisionados de forma gradual, evoluindo conforme o aluno avança no treinamento.

---

## 📐 Arquitetura da Solução

![Arquitetura AWS](./AWS-Architecture.png)

> 💡 Veja também o [diagrama interativo da arquitetura ECS](./docs/architecture/aws-ecs-diagram.html).

| Componente | Função |
|---|---|
| **ALB (Application Load Balancer)** | Distribuição de tráfego entre instâncias ECS |
| **ECS Cluster (EC2)** | Execução dos containers da aplicação BIA |
| **ECR** | Armazenamento e versionamento das imagens Docker |
| **RDS (PostgreSQL)** | Banco de dados relacional da aplicação |
| **CodePipeline + CodeBuild** | Automação completa de build e deploy contínuo |
| **GitHub** | Repositório de código — gatilho do pipeline |
| **Amazon Q + ECS MCP Server** | Agente de IA para provisionamento e gestão via linguagem natural |

---

## 🤖 Amazon Q em Ação

O grande diferencial deste projeto é a utilização do **Amazon Q Developer** com suporte ao **ECS MCP Server** (`awslabs-ecs-mcp-server`) para provisionar e gerenciar recursos AWS usando linguagem natural.

**Exemplos de comandos usados durante o projeto:**

```
"Crie um ECS Cluster com instâncias EC2 em us-east-1"
"Configure um ALB apontando para o target group do ECS"
"Crie um RDS PostgreSQL e conecte ao cluster ECS"
"Configure o CodePipeline integrado ao repositório GitHub para deploy automático"
```

**O ECS MCP Server permite:**
- Interações em linguagem natural com recursos ECS na AWS
- Monitoramento e gerenciamento da aplicação em execução
- Automação de tarefas de administração e suporte
- Troubleshooting acelerado com contexto de infraestrutura

> 💡 A configuração do MCP Server fica em `.amazonq/mcp.json`. As regras que guiam o comportamento do Amazon Q no projeto estão em `.amazonq/rules/`.

---

## ⚙️ Como Funciona o Pipeline de CI/CD

```
Push no GitHub
      │
      ▼
CodePipeline detecta alteração
      │
      ▼
CodeBuild executa buildspec-dynamic.yml
  ├── Detecta Account ID automaticamente (aws sts)
  ├── Login no ECR
  ├── docker build (Node 22 + Vite)
  ├── docker push (tag: latest + commit hash)
  └── Gera imagedefinitions.json
      │
      ▼
ECS atualiza o serviço com a nova imagem
      │
      ▼
ALB distribui o tráfego para os containers atualizados
```

Cada deploy é **rastreável por commit hash**, permitindo rollback rápido para qualquer versão anterior.

> ℹ️ O projeto inclui dois buildspecs:
> - `buildspec-dynamic.yml` — **recomendado**, detecta o Account ID automaticamente via `aws sts`
> - `buildspec.yml` — versão com Account ID fixo (útil para referência ou testes pontuais)

---

## 🏗️ Stack

- **Backend:** Node.js 22, Express, Sequelize ORM
- **Frontend:** React + Vite
- **Banco de dados:** PostgreSQL (via RDS)
- **Containerização:** Docker (imagem base `public.ecr.aws/docker/library/node:22-slim`)
- **Registry:** Amazon ECR
- **Orquestração:** Amazon ECS (EC2)
- **CI/CD:** AWS CodePipeline + CodeBuild
- **Balanceamento:** Application Load Balancer
- **IA:** Amazon Q Developer + ECS MCP Server (`awslabs-ecs-mcp-server`)

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado e configurado:

- [Docker](https://docs.docker.com/get-docker/) (v20+)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (v2) configurado com `aws configure`
- Node.js 22+
- Conta AWS com as seguintes permissões IAM:
  - `AmazonECS_FullAccess`
  - `AmazonEC2ContainerRegistryFullAccess`
  - `AmazonRDSFullAccess`
  - `ElasticLoadBalancingFullAccess`
  - `AWSCodePipelineFullAccess`
  - `AWSCodeBuildAdminAccess`

---

## 🚀 Como Executar

### 1. Clonar o repositório

```bash
git clone https://github.com/dev-edu1998/Automacao_com_Amazon_Q.git
cd Automacao_com_Amazon_Q
```

### 2. Configurar variáveis de ambiente

Configure as variáveis no `compose.yml`:

```yaml
services:
  server:
    environment:
      DB_SECRET_NAME: nome-do-secret
      DB_REGION: sua-regiao
      DB_HOST: endereco-do-banco
```

### 3. Rodar localmente

**Unix/macOS:**
```bash
chmod +x rodar_app_local_unix.sh
./rodar_app_local_unix.sh
```

**Windows:**
```bat
rodar_app_local_windows.bat
```

Ou manualmente com Docker:
```bash
# Sobe o banco de dados
docker compose up -d database

# Instala dependências e faz build do frontend
npm install --loglevel=error
npm run build --prefix client

# Roda as migrations
npx sequelize db:migrate

# Inicia a aplicação
npm start
```

### 4. Acessar a aplicação

```
http://localhost:8080
```

### 5. Verificar health check

```bash
curl http://localhost:8080/api/versao
```

---

## 🔐 Variáveis de Ambiente do CodeBuild

No console do AWS CodeBuild, configure as seguintes variáveis de ambiente no projeto de build:

| Variável | Descrição |
|---|---|
| `AWS_DEFAULT_REGION` | Região do deploy (ex: `us-east-1`) |
| `VITE_API_URL` | URL pública da API |

> ⚠️ **Nunca commite credenciais ou IDs de conta AWS diretamente no código.** Use variáveis de ambiente do CodeBuild. O `buildspec-dynamic.yml` detecta o `AWS_ACCOUNT_ID` automaticamente via `aws sts get-caller-identity`.

---

## 📂 Estrutura do Repositório

```
Automacao_com_Amazon_Q/
├── .amazonq/                     # Configuração do Amazon Q Developer
│   ├── mcp.json                  # Configuração do ECS MCP Server
│   └── rules/                    # Regras que guiam o Amazon Q no projeto
│       ├── dockerfile.md         # Padrões para geração de Dockerfiles
│       ├── infraestrutura.md     # Padrões de infraestrutura AWS
│       └── pipeline.md           # Padrões do pipeline CI/CD
├── api/                          # Backend Node.js
│   ├── controllers/              # Lógica das rotas
│   ├── models/                   # Modelos Sequelize
│   └── routes/                   # Definição das rotas Express
├── client/                       # Frontend React + Vite
│   ├── public/
│   └── src/
│       ├── components/
│       └── contexts/
├── config/                       # Configurações da aplicação (Express, DB)
├── database/
│   └── migrations/               # Migrations Sequelize
├── docs/
│   └── architecture/             # Diagrama interativo da arquitetura ECS
├── lib/                          # Boot e utilitários internos
├── scripts/
│   └── ecs/
│       ├── unix/                 # Scripts de build/deploy para Unix
│       └── windows/              # Scripts de build/deploy para Windows
├── tests/
│   └── unit/                     # Testes unitários Jest
├── AmazonQ.md                    # Análise técnica gerada pelo Amazon Q
├── AWS-Architecture.png          # Diagrama da arquitetura
├── Dockerfile                    # Imagem Docker da aplicação
├── buildspec.yml                 # Build com Account ID fixo
├── buildspec-dynamic.yml         # Build dinâmico (recomendado)
├── compose.yml                   # Configuração Docker para ambiente local
├── deploy-ecs.sh                 # Script completo de deploy no ECS
├── generate-sts-token.sh         # Geração de token STS temporário
├── rodar_app_local_unix.sh       # Atalho para rodar localmente (Unix)
├── rodar_app_local_windows.bat   # Atalho para rodar localmente (Windows)
└── README.md
```

---

## 🗂️ Amazon Q Rules

A pasta `.amazonq/rules/` contém as regras que orientam o Amazon Q ao trabalhar neste projeto:

| Arquivo | O que define |
|---|---|
| `dockerfile.md` | Usar imagem `public.ecr.aws/docker/library/node:22-slim`, single-stage, sem multi-stage builds |
| `infraestrutura.md` | Nomenclatura de recursos (`bia-cluster-alb`, `bia-tf`, `bia-service`), regras de Security Groups, uso de PostgreSQL |
| `pipeline.md` | Fluxo GitHub → CodeBuild → ECS, uso do `buildspec.yml`, permissões IAM mínimas |

---

## 🔧 Troubleshooting

**Erro de login no ECR:**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <sua-account-id>.dkr.ecr.us-east-1.amazonaws.com
```
Verifique se as permissões IAM incluem `ecr:GetAuthorizationToken`.

**Container não sobe localmente:**
Confirme que as variáveis do `compose.yml` estão preenchidas corretamente, especialmente `DB_HOST`.

**Pipeline não dispara após push:**
Verifique se o webhook do GitHub está configurado corretamente no CodePipeline e se o branch monitorado está correto (`main`).

**Build falha no CodeBuild:**
- Verifique os logs no CloudWatch
- Confirme que `AWS_DEFAULT_REGION` e `VITE_API_URL` estão configurados no projeto CodeBuild
- Se estiver usando `buildspec.yml`, valide que o Account ID está correto; prefira o `buildspec-dynamic.yml`

---

## ✨ Aprendizados

- Como provisionar recursos AWS usando **linguagem natural com Amazon Q**
- Construção de **pipelines CI/CD** com CodePipeline e CodeBuild
- Integração do **ECS MCP Server** como camada de IA sobre a infraestrutura
- Versionamento de imagens Docker por **commit hash** para rastreabilidade de deploys
- Boas práticas de nomenclatura e organização de recursos AWS

---

<p align="center">Desenvolvido durante o evento AWS & IA com o professor <a href="https://www.linkedin.com/in/henryllemaia/">Henrylle Maia</a></p>

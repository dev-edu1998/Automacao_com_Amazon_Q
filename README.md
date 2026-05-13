# 🚀 Deploy Automatizado na AWS com Amazon Q

<p align="left">
  <img src="https://img.shields.io/badge/AWS-ECS%20%7C%20ECR%20%7C%20ALB%20%7C%20RDS-FF9900?style=flat&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-22--slim-339933?style=flat&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/React-Vite-61DAFB?style=flat&logo=react&logoColor=black" />
  <img src="https://img.shields.io/badge/Docker-ECR-2496ED?style=flat&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/CI%2FCD-CodePipeline%20%7C%20CodeBuild-232F3E?style=flat&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Amazon%20Q-AI%20Agent-8A2BE2?style=flat&logo=amazonaws&logoColor=white" />
</p>

Projeto desenvolvido durante o evento **AWS & IA** do professor Henrylle Maia, com foco na criação de ambientes em **alta disponibilidade na AWS** utilizando **linguagem natural via Amazon Q Developer**.

A aplicação **BIA** é provisionada, construída e entregue automaticamente a cada push no GitHub — sem intervenção manual — graças a um pipeline completo de CI/CD integrado ao ECS, ECR, ALB e RDS.

---

## 📐 Arquitetura da Solução

![Arquitetura AWS](./AWS-Architecture.png)

| Componente | Função |
|---|---|
| **Route 53 + ACM** | Gerenciamento de DNS e certificados SSL |
| **ALB (Application Load Balancer)** | Distribuição de tráfego entre instâncias ECS |
| **ECS Cluster (EC2)** | Execução dos containers da aplicação BIA |
| **ECR** | Armazenamento e versionamento das imagens Docker |
| **RDS Multi-AZ** | Banco de dados relacional com alta disponibilidade |
| **CodePipeline + CodeBuild** | Automação completa de build e deploy contínuo |
| **GitHub** | Repositório de código — gatilho do pipeline |
| **Amazon Q + MCP Server** | Agente de IA para provisionamento e gestão via linguagem natural |

---

## 🤖 Amazon Q em Ação

O grande diferencial deste projeto é a utilização do **Amazon Q Developer** com suporte ao **MCP Server (Model Context Protocol)** para provisionar e gerenciar recursos AWS usando linguagem natural.

**Exemplos de comandos usados durante o projeto:**

```
"Crie um ECS Cluster com 2 instâncias EC2 em us-east-1 com alta disponibilidade"
"Configure um ALB apontando para o target group do ECS"
"Crie um RDS PostgreSQL Multi-AZ com failover automático"
"Configure o CodePipeline integrado ao repositório GitHub para deploy automático"
```

**O MCP Server permite:**
- Interações em linguagem natural com os recursos AWS
- Monitoramento e gerenciamento da aplicação em execução
- Automação de tarefas de administração e suporte
- Troubleshooting acelerado com contexto de infraestrutura

> 💡 Essa integração demonstra como IA + Cloud podem trabalhar em conjunto para aumentar produtividade e reduzir esforço operacional.

---

## ⚙️ Como Funciona o Pipeline de CI/CD

```
Push no GitHub
      │
      ▼
 CodePipeline detecta alteração
      │
      ▼
 CodeBuild executa buildspec.yml
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
      │
      ▼
 Aplicação disponível em https://labs.cloudopspro.tech
```

Cada deploy é **rastreável por commit hash**, permitindo rollback rápido para qualquer versão anterior.

---

## 🏗️ Stack Técnica

- **Backend:** Node.js 22, Sequelize ORM
- **Frontend:** React + Vite
- **Containerização:** Docker (imagem base `node:22-slim`)
- **Registry:** Amazon ECR
- **Orquestração:** Amazon ECS (EC2)
- **Banco de dados:** RDS Multi-AZ (PostgreSQL/MySQL)
- **CI/CD:** AWS CodePipeline + CodeBuild
- **Balanceamento:** Application Load Balancer
- **DNS/SSL:** Route 53 + ACM
- **IA:** Amazon Q Developer + MCP Server

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado e configurado:

- [Docker](https://docs.docker.com/get-docker/) (v20+)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (v2) configurado com `aws configure`
- Node.js 18+ (para rodar localmente)
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

Crie um arquivo `.env` na raiz do projeto:

```env
# AWS
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=sua-account-id
ECR_REPOSITORY=sua-account-id.dkr.ecr.us-east-1.amazonaws.com/bia

# Aplicação
VITE_API_URL=https://seu-dominio.com
PORT=8080

# Banco de dados
DB_HOST=seu-rds-endpoint
DB_PORT=5432
DB_NAME=seu-banco
DB_USER=seu-usuario
DB_PASS=sua-senha
```

### 3. Rodar localmente com Docker

```bash
# Build da imagem
docker build -t bia:local .

# Subir o container
docker compose up -d
```

### 4. Rodar as migrations do banco

```bash
docker compose exec server bash -c 'npx sequelize db:migrate'
```

### 5. Acessar a aplicação

```
http://localhost:8080
```

---

## 🔐 Variáveis de Ambiente do CodeBuild

No console do AWS CodeBuild, configure as seguintes variáveis de ambiente no projeto de build:

| Variável | Descrição |
|---|---|
| `AWS_ACCOUNT_ID` | ID da sua conta AWS |
| `AWS_DEFAULT_REGION` | Região do deploy (ex: `us-east-1`) |
| `VITE_API_URL` | URL pública da API |

> ⚠️ **Nunca commite IDs de conta AWS ou credenciais diretamente no código.** Use variáveis de ambiente do CodeBuild ou o AWS Secrets Manager.

---

## 📂 Estrutura do Repositório

```
Automacao_com_Amazon_Q/
├── client/               # Frontend React + Vite
│   ├── package.json
│   └── src/
├── src/                  # Backend Node.js
│   └── ...
├── buildspec.yml         # Instruções de build para o CodeBuild
├── Dockerfile            # Imagem Docker da aplicação
├── docker-compose.yml    # Configuração para ambiente local
├── AWS-Architecture.png  # Diagrama da arquitetura
└── README.md
```

---

## 🔧 Troubleshooting

**Erro de login no ECR:**
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <sua-account-id>.dkr.ecr.us-east-1.amazonaws.com
```
Verifique se as permissões IAM incluem `ecr:GetAuthorizationToken`.

**Container não sobe localmente:**
Confirme que as variáveis do `.env` estão preenchidas corretamente, especialmente `DB_HOST` e `DB_PORT`.

**Pipeline não dispara após push:**
Verifique se o webhook do GitHub está configurado corretamente no CodePipeline e se o branch monitorado é o correto (`main` ou `master`).

---

## ✨ Aprendizados

- Como provisionar recursos AWS usando **linguagem natural com Amazon Q**
- Boas práticas de **alta disponibilidade** com ECS Multi-AZ e RDS Multi-AZ
- Construção de **pipelines CI/CD** com CodePipeline e CodeBuild
- Integração de **MCP Server** como camada de IA sobre infraestrutura de produção
- Versionamento de imagens Docker por **commit hash** para rastreabilidade de deploys

Este projeto está sob a licença [MIT](LICENSE).

---

<p align="center">Desenvolvido durante o evento AWS & IA com o professor <a href="https://www.linkedin.com/in/henryllemaia/">Henrylle Maia</a></p>

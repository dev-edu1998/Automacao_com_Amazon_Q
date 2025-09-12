🚀 **Projeto AWS & IA – Ambiente em Nuvem com Deploy Automatizado**

Este projeto foi desenvolvido durante um evento sobre AWS & IA do professor Henrylle Maia, com foco na criação de ambientes em alta disponibilidade na nuvem da AWS, utilizando linguagem natural por meio do Amazon Q.

## 🏗️ Arquitetura da Solução  

![Arquitetura AWS](./AWS-Architecture.png)

### Componentes Principais:
- **Route 53 + ACM** → Gerenciamento de DNS e certificados SSL.  
- **ALB (Application Load Balancer)** → Distribuição de tráfego entre instâncias.  
- **ECS Cluster (EC2)** → Execução dos containers da aplicação.  
- **ECR** → Armazenamento das imagens Docker.  
- **RDS Multi-AZ** → Banco de dados relacional com alta disponibilidade.  
- **CodePipeline** → Automatização de build e deploy contínuo.  
- **GitHub** → Repositório de código integrado ao pipeline.  
- **AI Agent (EC2 Dev)** → Utilizado para auxiliar no desenvolvimento com suporte de IA.  







#### Para rodar as migrations no container ####
```
docker compose exec server bash -c 'npx sequelize db:migrate'
```


# AWS High Availability Environment with AI-Assisted Automation

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Docker](https://img.shields.io/badge/Docker-Containers-blue)
![CI/CD](https://img.shields.io/badge/CI/CD-Automation-green)
![Amazon Q](https://img.shields.io/badge/AmazonQ-AI-purple)
![ECS](https://img.shields.io/badge/AWS-ECS-ff9900)
![RDS](https://img.shields.io/badge/AWS-RDS-blue)

## Overview

This project demonstrates the implementation of a cloud-native AWS environment designed with high availability principles, automated CI/CD pipelines, containerized workloads, and AI-assisted infrastructure provisioning using Amazon Q.

The environment was developed during an AWS & AI event led by Henrylle Maia, focusing on modern DevOps practices, scalability, automation, and cloud infrastructure management using natural language interactions with AWS services.

Although Amazon Q was used to accelerate infrastructure provisioning and workflow automation, all generated solutions were manually validated, adapted, and integrated based on prior knowledge of Cloud Computing, Linux administration, and DevOps concepts.

---

## Features

- High Availability AWS Architecture
- Automated CI/CD Pipeline
- Dockerized Application Deployment
- ECS Cluster Running on EC2
- Multi-AZ Relational Database
- Load Balancing with SSL Termination
- AI-Assisted Infrastructure Provisioning
- GitHub Integration with AWS Services
- Natural Language Cloud Operations Support

---

# Architecture

![AWS Architecture](./AWS-Architecture.png)

---

## Architecture Components

### Route 53 + ACM
Responsible for DNS management and SSL certificate provisioning.

### Application Load Balancer (ALB)
Distributes incoming traffic between application instances, improving availability and resilience.

### ECS Cluster (EC2 Launch Type)
Runs the containerized application within an ECS cluster using EC2 instances.

### Amazon ECR
Stores Docker container images used during the deployment process.

### Amazon RDS Multi-AZ
Provides a highly available relational database setup with automatic failover capabilities.

### AWS CodePipeline
Automates the build and deployment workflow, enabling continuous integration and delivery.

### GitHub Repository
Acts as the source control platform integrated with the CI/CD pipeline.

### AI Agent (Development EC2)
Environment used alongside Amazon Q to assist with infrastructure provisioning, automation, and operational workflows.

---

# AI-Assisted Infrastructure Management

This project integrates an MCP Server (Model Context Protocol) acting as an intelligent operational assistant connected to the AWS infrastructure.

The integration enables:

- Natural language interactions with AWS resources
- Operational troubleshooting assistance
- Environment monitoring support
- Infrastructure management automation
- Productivity improvements during development workflows
- Faster operational tasks execution

This demonstrates how AI and Cloud Computing can work together to improve operational efficiency and reduce manual overhead.

---

# Deployment Workflow

The deployment process follows an automated CI/CD workflow:

1. Code changes are pushed to GitHub
2. AWS CodePipeline detects repository updates
3. Build stage is triggered automatically
4. Docker image is generated and stored in Amazon ECR
5. ECS services are updated automatically
6. Application becomes available through the Load Balancer

This workflow reduces manual intervention and simulates production-oriented DevOps practices.

---

# Repository Structure

```bash
├── src/                # Application source code
├── buildspec.yml       # AWS CodeBuild instructions
├── Dockerfile          # Container image definition
├── README.md           # Project documentation

#!/usr/bin/env bash

# Script de Deploy ECS - Projeto BIA
# Este script automatiza o processo de build e deploy para ECS
# com versionamento baseado em commit hash para facilitar rollbacks

set -e  


DEFAULT_REGION="us-east-1"
DEFAULT_ECR_REPO="bia"
DEFAULT_CLUSTER="cluster-bia-alb"
DEFAULT_SERVICE="service-bia-alb"
DEFAULT_TASK_FAMILY="task-def-bia-alb"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


show_help() {
    cat << EOF
Script de Deploy ECS - Projeto BIA

USAGE:
    ./deploy-ecs-fixed.sh [COMMAND] [OPTIONS]

COMMANDS:
    deploy          Faz build da imagem e deploy para ECS
    rollback        Faz rollback para uma versão anterior
    list-versions   Lista as versões disponíveis no ECR
    help            Mostra esta ajuda

OPTIONS:
    -r, --region REGION         Região AWS (default: $DEFAULT_REGION)
    -e, --ecr-repo REPO         Nome do repositório ECR (default: $DEFAULT_ECR_REPO)
    -c, --cluster CLUSTER       Nome do cluster ECS (default: $DEFAULT_CLUSTER)
    -s, --service SERVICE       Nome do serviço ECS (default: $DEFAULT_SERVICE)
    -f, --task-family FAMILY    Família da task definition (default: $DEFAULT_TASK_FAMILY)
    -t, --tag TAG               Tag específica para rollback
    -h, --help                  Mostra esta ajuda

EXAMPLES:
    # Deploy normal (usa commit hash atual)
    ./deploy-ecs-fixed.sh deploy

    # Deploy com configurações customizadas
    ./deploy-ecs-fixed.sh deploy -r us-west-2 -e meu-repo

    # Rollback para uma versão específica
    ./deploy-ecs-fixed.sh rollback -t abc1234

    # Listar versões disponíveis
    ./deploy-ecs-fixed.sh list-versions

EOF
}


get_commit_hash() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git rev-parse --short=7 HEAD
    else
        log_error "Este diretório não é um repositório Git"
        exit 1
    fi
}


ecr_login() {
    local region=$1
    log_info "Fazendo login no ECR..."
    aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com
}


check_ecr_repo() {
    local region=$1
    local repo_name=$2
    
    log_info "Verificando repositório ECR: $repo_name"
    if ! aws ecr describe-repositories --repository-names $repo_name --region $region > /dev/null 2>&1; then
        log_error "Repositório ECR '$repo_name' não encontrado na região '$region'"
        log_info "Crie o repositório com: aws ecr create-repository --repository-name $repo_name --region $region"
        exit 1
    fi
}


build_image() {
    local tag=$1
    local ecr_uri=$2
    
    log_info "Fazendo build da imagem Docker..."
    log_info "Tag: $tag"
    
   
    docker build -t bia-app:$tag -t bia-app:latest -t $ecr_uri:$tag -t $ecr_uri:latest .
    
    log_success "Build concluído com sucesso"
}


push_image() {
    local tag=$1
    local ecr_uri=$2
    
    log_info "Fazendo push da imagem para ECR..."
    docker push $ecr_uri:$tag
    docker push $ecr_uri:latest
    
    log_success "Push concluído com sucesso"
}


create_task_definition() {
    local region=$1
    local task_family=$2
    local ecr_uri=$3
    local tag=$4
    
    log_info "Criando nova task definition..."
    

    local current_task_def=$(aws ecs describe-task-definition --task-definition $task_family --region $region --query 'taskDefinition' --output json 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        log_error "Não foi possível obter a task definition atual: $task_family"
        exit 1
    fi
    
  
    local execution_role=$(echo "$current_task_def" | jq -r '.executionRoleArn // empty')
    local task_role=$(echo "$current_task_def" | jq -r '.taskRoleArn // empty')
    local network_mode=$(echo "$current_task_def" | jq -r '.networkMode // "bridge"')
    local volumes=$(echo "$current_task_def" | jq -c '.volumes // []')
    local cpu=$(echo "$current_task_def" | jq -r '.cpu // empty')
    local memory=$(echo "$current_task_def" | jq -r '.memory // empty')
    local requires_compatibilities=$(echo "$current_task_def" | jq -c '.requiresCompatibilities // []')
    

    local container_defs=$(echo "$current_task_def" | jq --arg image "$ecr_uri:$tag" '.containerDefinitions[0].image = $image | .containerDefinitions')
    
    log_info "Registrando nova task definition com imagem: $ecr_uri:$tag"
    

    local temp_file=$(mktemp)
    echo "$container_defs" > "$temp_file"
    

    local aws_cmd="aws ecs register-task-definition --region $region --family $task_family --container-definitions file://$temp_file"

    if [ ! -z "$execution_role" ] && [ "$execution_role" != "null" ] && [ "$execution_role" != "" ]; then
        aws_cmd="$aws_cmd --execution-role-arn $execution_role"
    fi
    

    if [ ! -z "$task_role" ] && [ "$task_role" != "null" ] && [ "$task_role" != "" ]; then
        aws_cmd="$aws_cmd --task-role-arn $task_role"
    fi
    

    if [ ! -z "$network_mode" ] && [ "$network_mode" != "null" ] && [ "$network_mode" != "" ]; then
        aws_cmd="$aws_cmd --network-mode $network_mode"
    fi
    

    if [ ! -z "$cpu" ] && [ "$cpu" != "null" ] && [ "$cpu" != "" ]; then
        aws_cmd="$aws_cmd --cpu $cpu"
    fi

    
    if [ ! -z "$memory" ] && [ "$memory" != "null" ] && [ "$memory" != "" ]; then
        aws_cmd="$aws_cmd --memory $memory"
    fi

    
    if [ "$requires_compatibilities" != "[]" ] && [ "$requires_compatibilities" != "null" ]; then
        local compat_file=$(mktemp)
        echo "$requires_compatibilities" > "$compat_file"
        aws_cmd="$aws_cmd --requires-compatibilities file://$compat_file"
    fi
    

    if [ "$volumes" != "[]" ] && [ "$volumes" != "null" ]; then
        local volumes_file=$(mktemp)
        echo "$volumes" > "$volumes_file"
        aws_cmd="$aws_cmd --volumes file://$volumes_file"
    fi
    
    aws_cmd="$aws_cmd --output json"
    

    local register_response
    register_response=$(eval $aws_cmd 2>&1)
    local register_exit_code=$?
    

    rm -f "$temp_file"
    if [ ! -z "$compat_file" ]; then
        rm -f "$compat_file"
    fi
    if [ ! -z "$volumes_file" ]; then
        rm -f "$volumes_file"
    fi
    
    if [ $register_exit_code -ne 0 ]; then
        log_error "Falha ao registrar nova task definition"
        log_error "Comando: $aws_cmd"
        log_error "Resposta: $register_response"
        exit 1
    fi
    

    local new_revision=$(echo "$register_response" | jq -r '.taskDefinition.revision')
    
    if [ "$new_revision" = "null" ] || [ -z "$new_revision" ]; then
        log_error "Não foi possível obter o número da revisão da nova task definition"
        log_error "Resposta completa: $register_response"
        exit 1
    fi
    
    log_success "Nova task definition criada: $task_family:$new_revision"
    echo "$new_revision"
}


update_service() {
    local region=$1
    local cluster=$2
    local service=$3
    local task_family=$4
    local revision=$5
    
    log_info "Atualizando serviço ECS..."
    log_info "Task Definition: $task_family:$revision"
    
    local update_response
    update_response=$(aws ecs update-service \
        --region $region \
        --cluster $cluster \
        --service $service \
        --task-definition $task_family:$revision \
        --output json 2>&1)
    
    if [ $? -ne 0 ]; then
        log_error "Falha ao atualizar o serviço ECS"
        log_error "Resposta: $update_response"
        exit 1
    fi
    
    log_success "Serviço atualizado com sucesso"
    log_info "Aguardando estabilização do serviço..."
    
    aws ecs wait services-stable --region $region --cluster $cluster --services $service
    
    if [ $? -eq 0 ]; then
        log_success "Deploy concluído com sucesso!"
    else
        log_warning "Timeout aguardando estabilização do serviço. Verifique o status manualmente."
    fi
}


list_versions() {
    local region=$1
    local repo_name=$2
    
    log_info "Listando versões disponíveis no ECR..."
    
    aws ecr describe-images \
        --repository-name $repo_name \
        --region $region \
        --query 'sort_by(imageDetails,&imagePushedAt)[*].[imageTags[0],imagePushedAt]' \
        --output table
}


deploy() {
    local region=$1
    local ecr_repo=$2
    local cluster=$3
    local service=$4
    local task_family=$5
    

    local commit_hash=$(get_commit_hash)
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    local ecr_uri="$account_id.dkr.ecr.$region.amazonaws.com/$ecr_repo"
    
    log_info "Iniciando deploy..."
    log_info "Commit Hash: $commit_hash"
    log_info "ECR URI: $ecr_uri"
    

    check_ecr_repo $region $ecr_repo
    

    ecr_login $region
    

    build_image $commit_hash $ecr_uri
    
 
    push_image $commit_hash $ecr_uri
    

    log_info "Criando nova task definition..."
    local new_revision
    new_revision=$(create_task_definition $region $task_family $ecr_uri $commit_hash)
    
    if [ -z "$new_revision" ] || [ "$new_revision" = "null" ]; then
        log_error "Falha ao obter revision da nova task definition"
        log_error "Valor retornado: '$new_revision'"
        exit 1
    fi
    
    log_info "Nova revisão criada: $new_revision"
    
  
    update_service $region $cluster $service $task_family $new_revision
    
    log_success "Deploy concluído!"
    log_info "Versão deployada: $commit_hash"
    log_info "Task Definition: $task_family:$new_revision"
}


rollback() {
    local region=$1
    local ecr_repo=$2
    local cluster=$3
    local service=$4
    local task_family=$5
    local target_tag=$6
    
    if [ -z "$target_tag" ]; then
        log_error "Tag para rollback não especificada. Use -t ou --tag"
        exit 1
    fi
    
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    local ecr_uri="$account_id.dkr.ecr.$region.amazonaws.com/$ecr_repo"
    
    log_info "Iniciando rollback para versão: $target_tag"
    

    if ! aws ecr describe-images --repository-name $ecr_repo --region $region --image-ids imageTag=$target_tag > /dev/null 2>&1; then
        log_error "Imagem com tag '$target_tag' não encontrada no ECR"
        exit 1
    fi
    

    local new_revision
    new_revision=$(create_task_definition $region $task_family $ecr_uri $target_tag)
    

    update_service $region $cluster $service $task_family $new_revision
    
    log_success "Rollback concluído!"
    log_info "Versão atual: $target_tag"
    log_info "Task Definition: $task_family:$new_revision"
}


REGION=$DEFAULT_REGION
ECR_REPO=$DEFAULT_ECR_REPO
CLUSTER=$DEFAULT_CLUSTER
SERVICE=$DEFAULT_SERVICE
TASK_FAMILY=$DEFAULT_TASK_FAMILY
COMMAND=""
TARGET_TAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        deploy|rollback|list-versions|help)
            COMMAND=$1
            shift
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -e|--ecr-repo)
            ECR_REPO="$2"
            shift 2
            ;;
        -c|--cluster)
            CLUSTER="$2"
            shift 2
            ;;
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -f|--task-family)
            TASK_FAMILY="$2"
            shift 2
            ;;
        -t|--tag)
            TARGET_TAG="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done


if [ -z "$COMMAND" ]; then
    log_error "Nenhum comando especificado"
    show_help
    exit 1
fi


if ! command -v aws &> /dev/null; then
    log_error "AWS CLI não encontrado. Instale o AWS CLI primeiro."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    log_error "Docker não encontrado. Instale o Docker primeiro."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    log_error "jq não encontrado. Instale o jq primeiro."
    exit 1
fi


case $COMMAND in
    deploy)
        deploy $REGION $ECR_REPO $CLUSTER $SERVICE $TASK_FAMILY
        ;;
    rollback)
        rollback $REGION $ECR_REPO $CLUSTER $SERVICE $TASK_FAMILY $TARGET_TAG
        ;;
    list-versions)
        list_versions $REGION $ECR_REPO
        ;;
    help)
        show_help
        ;;
    *)
        log_error "Comando desconhecido: $COMMAND"
        show_help
        exit 1
        ;;
esac

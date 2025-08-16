#!/bin/bash

# Script de Deploy Manual para Harpia Metrics
# Uso: ./deploy.sh [start|stop|restart|status|logs|clean]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="harpia-metrics"

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Função para verificar se Docker está rodando
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        error "Docker não está rodando ou não tem permissões"
        exit 1
    fi
}

# Função para verificar se Docker Compose está disponível
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não está instalado"
        exit 1
    fi
}

# Função para verificar redes Docker
check_networks() {
    info "Verificando redes Docker..."
    
    if ! docker network ls | grep -q "harpia-network"; then
        warn "Rede 'harpia-network' não encontrada. Criando..."
        docker network create harpia-network
    fi
    
    if ! docker network ls | grep -q "manager-tenants-network"; then
        warn "Rede 'manager-tenants-network' não encontrada. Criando..."
        docker network create manager-tenants-network
    fi
    
    log "Redes Docker verificadas/criadas com sucesso"
}

# Função para iniciar serviços
start_services() {
    log "Iniciando serviços..."
    check_networks
    docker-compose -f "$COMPOSE_FILE" up -d
    log "Serviços iniciados. Aguardando inicialização..."
    sleep 10
    check_health
}

# Função para parar serviços
stop_services() {
    log "Parando serviços..."
    docker-compose -f "$COMPOSE_FILE" down --remove-orphans
    log "Serviços parados"
}

# Função para reiniciar serviços
restart_services() {
    log "Reiniciando serviços..."
    stop_services
    start_services
}

# Função para verificar status
show_status() {
    log "Status dos serviços:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    echo ""
    log "Redes Docker:"
    docker network ls | grep -E "(harpia|manager-tenants)"
    
    echo ""
    log "Volumes Docker:"
    docker volume ls | grep -E "(prometheus|grafana)"
}

# Função para mostrar logs
show_logs() {
    log "Logs dos serviços (últimas 50 linhas):"
    docker-compose -f "$COMPOSE_FILE" logs --tail=50
}

# Função para health check
check_health() {
    log "Verificando saúde dos serviços..."
    
    # Verificar Prometheus
    if curl -f http://localhost:9090/-/healthy > /dev/null 2>&1; then
        log "✅ Prometheus está saudável"
    else
        error "❌ Prometheus não está respondendo"
        return 1
    fi
    
    # Verificar Grafana
    if curl -f http://localhost:3017/api/health > /dev/null 2>&1; then
        log "✅ Grafana está saudável"
    else
        error "❌ Grafana não está respondendo"
        return 1
    fi
    
    log "🎉 Todos os serviços estão saudáveis!"
    echo ""
    info "Prometheus: http://localhost:9090"
    info "Grafana: http://localhost:3017 (admin/admin)"
}

# Função para limpeza
cleanup() {
    log "Limpando recursos Docker não utilizados..."
    docker system prune -f
    docker volume prune -f
    log "Limpeza concluída"
}

# Função para mostrar ajuda
show_help() {
    echo "Script de Deploy para Harpia Metrics"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start     - Iniciar todos os serviços"
    echo "  stop      - Parar todos os serviços"
    echo "  restart   - Reiniciar todos os serviços"
    echo "  status    - Mostrar status dos serviços"
    echo "  logs      - Mostrar logs dos serviços"
    echo "  health    - Verificar saúde dos serviços"
    echo "  clean     - Limpar recursos Docker não utilizados"
    echo "  help      - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
}

# Função principal
main() {
    # Verificar pré-requisitos
    check_docker
    check_docker_compose
    
    case "${1:-help}" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        health)
            check_health
            ;;
        clean|cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Comando inválido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@" 
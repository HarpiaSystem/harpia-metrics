pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        PROJECT_NAME = 'harpia-metrics'
        GITHUB_REPO = 'HarpiaSystem/harpia-metrics'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Fazendo checkout do código...'
                checkout scm
            }
        }
        
        stage('Validate Docker Compose') {
            steps {
                echo '🔍 Validando arquivo docker-compose.yml...'
                sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} config'
            }
        }
        
        stage('Stop Existing Containers') {
            steps {
                echo '🛑 Parando containers existentes...'
                script {
                    try {
                        sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} down --remove-orphans'
                    } catch (Exception e) {
                        echo "⚠️ Nenhum container rodando ou erro ao parar: ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('Cleanup Volumes') {
            steps {
                echo '🧹 Limpando volumes antigos...'
                script {
                    try {
                        sh 'docker volume prune -f'
                        sh 'docker system prune -f'
                    } catch (Exception e) {
                        echo "⚠️ Erro na limpeza: ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('Deploy Services') {
            steps {
                echo '🚀 Iniciando serviços...'
                sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} up -d'
            }
        }
        
        stage('Health Check') {
            steps {
                echo '🏥 Verificando saúde dos serviços...'
                script {
                    // Aguardar serviços iniciarem
                    sleep(time: 30, unit: 'SECONDS')
                    
                    // Verificar Prometheus
                    try {
                        sh 'curl -f http://localhost:9090/-/healthy || exit 1'
                        echo '✅ Prometheus está saudável'
                    } catch (Exception e) {
                        echo '❌ Prometheus não está respondendo'
                        error 'Prometheus health check falhou'
                    }
                    
                    // Verificar Grafana
                    try {
                        sh 'curl -f http://localhost:3017/api/health || exit 1'
                        echo '✅ Grafana está saudável'
                    } catch (Exception e) {
                        echo '❌ Grafana não está respondendo'
                        error 'Grafana health check falhou'
                    }
                }
            }
        }
        
        stage('Verify Networks') {
            steps {
                echo '🌐 Verificando redes Docker...'
                script {
                    try {
                        sh 'docker network ls | grep harpia-network || echo "⚠️ Rede harpia-network não encontrada"'
                        sh 'docker network ls | grep manager-tenants-network || echo "⚠️ Rede manager-tenants-network não encontrada"'
                    } catch (Exception e) {
                        echo "⚠️ Erro ao verificar redes: ${e.getMessage()}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '📊 Status final dos containers:'
            sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} ps'
            
            echo '📈 Logs dos últimos 20 segundos:'
            sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} logs --tail=20 || true'
        }
        
        success {
            echo '🎉 Deploy realizado com sucesso!'
            echo '📊 Prometheus: http://localhost:9090'
            echo '📈 Grafana: http://localhost:3017 (admin/admin)'
        }
        
        failure {
            echo '💥 Deploy falhou!'
            echo '📋 Logs de erro:'
            sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} logs --tail=50 || true'
        }
        
        cleanup {
            echo '🧹 Limpeza final...'
            sh 'docker system prune -f || true'
        }
    }
} 
# Configuração do Jenkins para Harpia Metrics

## 📋 Pré-requisitos no Servidor Jenkins

### 1. Plugins Necessários
- **Pipeline** (já incluído no Jenkins)
- **Git** (para checkout do código)
- **Docker Pipeline** (opcional, para comandos Docker avançados)

### 2. Ferramentas no Servidor
- **Docker** instalado e configurado
- **Docker Compose** instalado
- **Git** configurado
- **curl** para health checks

### 3. Permissões
- Usuário Jenkins deve ter acesso ao grupo `docker`
- Usuário Jenkins deve ter permissões para executar comandos Docker

## 🚀 Configuração do Job no Jenkins

### 1. Criar Novo Job
1. Acesse o Jenkins
2. Clique em "New Item"
3. Digite o nome: `harpia-metrics-deploy`
4. Selecione "Pipeline"
5. Clique em "OK"

### 2. Configurações do Job

#### **General**
- ✅ **Discard old builds** (manter apenas os últimos 10 builds)
- ✅ **This project is parameterized** (opcional, para versões específicas)

#### **Build Triggers**
- ✅ **Poll SCM** (verificar mudanças a cada 5 minutos)
  - Schedule: `H/5 * * * *`
- ✅ **GitHub hook trigger for GITScm polling** (se usar webhooks)

#### **Pipeline**
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `git@github.com:HarpiaSystem/harpia-metrics.git`
- **Credentials**: Seu usuário SSH do GitHub
- **Branch Specifier**: `*/main`
- **Script Path**: `Jenkinsfile`

### 3. Configurações Avançadas

#### **Environment Variables**
```
DOCKER_COMPOSE_FILE=docker-compose.yml
PROJECT_NAME=harpia-metrics
GITHUB_REPO=HarpiaSystem/harpia-metrics
```

#### **Build Triggers**
- **Build after other projects are built**: Se depender de outros jobs
- **Build periodically**: Para builds automáticos (ex: `0 2 * * *` - 2h da manhã)

## 🔧 Configurações do Servidor

### 1. Adicionar Usuário Jenkins ao Grupo Docker
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 2. Verificar Redes Docker
```bash
# Criar redes se não existirem
docker network create harpia-network
docker network create manager-tenants-network
```

### 3. Configurar SSH Keys
```bash
# No usuário jenkins
sudo -u jenkins ssh-keygen -t rsa -b 4096 -C "jenkins@servidor"
# Adicionar chave pública ao GitHub
```

## 📊 Monitoramento do Pipeline

### 1. Métricas de Sucesso
- Taxa de sucesso dos builds
- Tempo de execução
- Status dos health checks

### 2. Alertas
- Falha no deploy
- Serviços não respondendo
- Erros de rede Docker

### 3. Logs
- Logs do Jenkins
- Logs dos containers
- Logs de erro

## 🚨 Troubleshooting

### Problemas Comuns

#### **Permissão Negada no Docker**
```bash
sudo chmod 666 /var/run/docker.sock
# OU
sudo usermod -aG docker jenkins
```

#### **Redes Docker Não Encontradas**
```bash
docker network create harpia-network
docker network create manager-tenants-network
```

#### **Portas Já em Uso**
```bash
# Verificar processos usando as portas
sudo netstat -tulpn | grep :9090
sudo netstat -tulpn | grep :3017

# Parar processos conflitantes
sudo docker-compose down
```

#### **Health Check Falhando**
```bash
# Verificar logs dos containers
docker-compose logs prometheus
docker-compose logs grafana

# Verificar status dos containers
docker-compose ps
```

## 🔄 Atualizações e Manutenção

### 1. Atualizar Jenkinsfile
- Commit e push para o GitHub
- Jenkins detectará automaticamente as mudanças
- Novo build será executado

### 2. Rollback
- Jenkins mantém histórico de builds
- Pode fazer rollback para versão anterior
- Usar tag específica do Git

### 3. Backup
- Backup dos volumes Docker
- Backup das configurações
- Backup dos logs

## 📈 Próximos Passos

1. **Configurar Webhooks** para builds automáticos
2. **Implementar testes** antes do deploy
3. **Adicionar notificações** (Slack, email)
4. **Configurar monitoramento** do próprio Jenkins
5. **Implementar blue-green deployment** 
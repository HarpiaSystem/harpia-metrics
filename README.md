# Harpia Metrics

Sistema de monitoramento e métricas para o Harpia System, utilizando Prometheus e Grafana para coleta e visualização de dados de performance.

## 🚀 Tecnologias

- **Prometheus**: Coleta e armazenamento de métricas
- **Grafana**: Visualização e dashboards
- **Docker Compose**: Orquestração dos serviços

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Redes Docker externas configuradas:
  - `harpia-network`
  - `manager-tenants-network`

## 🛠️ Instalação e Execução

1. **Clone o repositório:**
   ```bash
   git clone <seu-repo-url>
   cd harpia_metrics
   ```

2. **Execute os serviços:**
   ```bash
   docker-compose up -d
   ```

3. **Acesse os serviços:**
   - **Prometheus**: http://localhost:9090
   - **Grafana**: http://localhost:3017
     - Usuário: `admin`
     - Senha: `admin`

## 📊 Serviços Monitorados

O sistema coleta métricas dos seguintes serviços:

- **Harpia API** (porta 4001)
- **ProxySQL** (porta 6032)
- **Redis** (porta 6379)
- **Sentinel API** (porta 7771)
- **MariaDB Sentinel** (porta 3306)
- **Redis Sentinel** (porta 6379)
- **Serviços dinâmicos** (descoberta via DNS)

## 🔧 Configuração

### Prometheus
- Arquivo de configuração: `prometheus/prometheus.yml`
- Intervalo de coleta: 15 segundos
- Armazenamento: Volume Docker persistente

### Grafana
- Porta: 3017 (mapeada para 3000 do container)
- Dados persistidos em volume Docker

## 📁 Estrutura do Projeto

```
harpia_metrics/
├── docker-compose.yml      # Orquestração dos serviços
├── prometheus/
│   └── prometheus.yml      # Configuração do Prometheus
├── .gitignore             # Arquivos ignorados pelo Git
└── README.md              # Este arquivo
```

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença [MIT](LICENSE).

## 🆘 Suporte

Para suporte, entre em contato com a equipe do Harpia System. 
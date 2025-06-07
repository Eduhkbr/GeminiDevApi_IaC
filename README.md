# GeminiDevApi_IaC

Este repositório contém a infraestrutura como código (IaC) para o projeto GeminiDevApi. A infraestrutura é gerenciada com o Terraform e implantada no Google Cloud Platform (GCP).

## Arquitetura

O projeto utiliza os seguintes componentes:

* **Google Cloud SQL (PostgreSQL):** para o banco de dados principal.
* **Google Cloud Memorystore (Redis):** para cache.
* **Google Cloud Run:** para hospedar a aplicação (implícito pela imagem do Docker e workflow).
* **Grafana:** para monitoramento e visualização de métricas da aplicação.
* **GitHub Actions:** para automação de CI/CD e implantação da infraestrutura.

## Pré-requisitos

Antes de começar, você precisará ter o seguinte:

* Uma conta do Google Cloud Platform com um projeto criado.
* Credenciais de uma conta de serviço do GCP com as permissões necessárias para criar os recursos.
* O Terraform instalado (versão 1.6.0 ou superior).
* Acesso a um repositório de imagens de contêiner (como o Google Container Registry) para a imagem da aplicação.

## Configuração

A configuração da infraestrutura é feita através de variáveis de ambiente, que são utilizadas pelo Terraform. Essas variáveis devem ser configuradas como segredos no seu repositório do GitHub para serem usadas pelo workflow de CI/CD.

As seguintes variáveis são necessárias:

* `DB_NAME`: O nome do banco de dados a ser criado na instância do Cloud SQL.
* `DB_USER`: O nome de usuário para o banco de dados.
* `DB_PASSWORD`: A senha para o usuário do banco de dados.
* `GCP_PROJECT_ID`: O ID do seu projeto no GCP.
* `IMAGE_URL`: A URL da imagem Docker da sua aplicação.
* `DB_INSTANCE_NAME`: O nome da instância do Cloud SQL.
* `REDIS_INSTANCE_NAME`: O nome da instância do Redis.
* `GCP_REGION`: A região do GCP onde os recursos serão implantados.
* `GOOGLE_APPLICATION_CREDENTIALS`: As credenciais da sua conta de serviço do GCP em formato JSON.

## Implantação

A implantação da infraestrutura é automatizada através de um workflow do GitHub Actions definido em `.github/workflows/terraform.yml`. O workflow é acionado a cada `push` para a branch `main`.

O workflow executa os seguintes passos:

1.  **Checkout do código:** Baixa o código do repositório.
2.  **Configuração do Terraform:** Instala e configura o Terraform.
3.  **Autenticação no Google Cloud:** Autentica-se no GCP usando as credenciais da conta de serviço.
4.  **Terraform Init:** Inicializa o Terraform.
5.  **Importação de Recursos Existentes:** Tenta importar instâncias existentes do Cloud SQL e Redis para evitar conflitos.
6.  **Terraform Plan:** Gera um plano de execução do que será criado/modificado.
7.  **Terraform Apply:** Aplica as mudanças para criar ou atualizar a infraestrutura. Este passo só é executado na branch `main`.

## Monitoramento

O projeto inclui um dashboard pré-configurado para o Grafana, que monitora várias métricas da aplicação.

O dashboard está definido em `grafana/dashboards/api_dashboards.json` e o provisionamento é configurado em `grafana/provisioning/dashboards/dashboard-provider.yml`. A fonte de dados do Prometheus é configurada em `grafana/provisioning/datasources/prometheus-datasource.yml`.

As métricas monitoradas incluem:

* **Uptime do processo**
* **Uso de CPU do processo**
* **Chamadas à IA**
* **Acertos no Cache**
* **Taxa de Requisições HTTP**
* **Latência de Resposta**
* **Uso de Memória da JVM (Heap e Non-Heap)**
* **Threads da JVM**
* **Uso do Pool de Conexões do Banco de Dados**
* **Timeouts do Pool de Conexões**

## Banco de Dados

O script de inicialização do banco de dados `terraform/init.sql` define as seguintes tabelas:

* **users:** Armazena informações dos usuários, incluindo nome de usuário, hash da senha e role.
* **generation_cache:** Armazena o cache de gerações, incluindo o hash do código-fonte, o resultado e o nome.

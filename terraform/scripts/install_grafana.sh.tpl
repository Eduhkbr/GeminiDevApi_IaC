#!/bin/bash
# Instalação do Grafana
sudo apt-get update
sudo apt-get install -y apt-transport-https wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Provisionamento
sudo mkdir -p /etc/grafana/provisioning/datasources /etc/grafana/provisioning/dashboards /var/lib/grafana/dashboards

# Injeta os conteúdos dos arquivos
cat <<EOF | sudo tee /etc/grafana/provisioning/datasources/prometheus.yml
${prometheus_datasource_yml}
EOF
cat <<EOF | sudo tee /etc/grafana/provisioning/dashboards/dashboards.yml
${dashboard_provider_yml}
EOF
cat <<EOF | sudo tee /var/lib/grafana/dashboards/api_dashboards.json
${api_dashboards_json}
EOF

# Reinicia o Grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service
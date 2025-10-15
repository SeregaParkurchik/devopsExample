#!/bin/bash
echo "🚀 Starting Yandex Cloud cluster..."

# 1. Создаем инфраструктуру
cd terraform
terraform init
terraform apply -auto-approve

# 2. Получаем новый IP и kubeconfig
terraform output -raw kubernetes_cluster_external_ip > ../cluster_ip.txt
terraform output -raw kubeconfig > ~/.kube/config

# 3. Обновляем секреты в GitHub
NEW_IP=$(cat ../cluster_ip.txt)
echo "📝 New Cluster IP: $NEW_IP"
echo ""
echo "🔐 Update GitHub Secrets:"
echo "   YC_LOAD_BALANCER_IP: $NEW_IP"
echo "   YC_KUBECONFIG: (content of ~/.kube/config)"

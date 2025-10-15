#!/bin/bash
echo "📦 Deploying applications to cluster..."

# 1. Проверяем доступность кластера
kubectl cluster-info

# 2. Применяем все манифесты
kubectl apply -f k8s/

# 3. Ждем запуска подов
kubectl wait --for=condition=ready pod -l app=backend-go --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend-next --timeout=300s

# 4. Проверяем статус
kubectl get pods
kubectl get services
kubectl get ingress

echo "✅ Applications deployed!"
CLUSTER_IP=$(kubectl get ingress main-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "🌐 Your application: http://$CLUSTER_IP/"

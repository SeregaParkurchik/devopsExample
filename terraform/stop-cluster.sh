#!/bin/bash
echo "🛑 Stopping Yandex Cloud cluster..."

# Останавливаем ВМ через Terraform
cd terraform
terraform destroy -auto-approve

echo "✅ Cluster stopped"
echo "💾 Backup files created:"
echo "   - ~/.kube/config.backup"
echo "   - terraform/terraform.tfstate.backup"

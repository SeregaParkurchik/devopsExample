terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

# VPC сеть
resource "yandex_vpc_network" "devops-network" {
  name = "devops-network"
}

# Подсеть
resource "yandex_vpc_subnet" "devops-subnet" {
  name           = "devops-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.devops-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Service Account для Kubernetes
resource "yandex_iam_service_account" "k8s-admin" {
  name        = "k8s-admin"
  description = "Service account for Kubernetes cluster"
}

# Статический ключ для доступа
resource "yandex_iam_service_account_static_access_key" "k8s-sa-key" {
  service_account_id = yandex_iam_service_account.k8s-admin.id
}

output "k8s_service_account_key" {
  value     = yandex_iam_service_account_static_access_key.k8s-sa-key.secret_key
  sensitive = true
}
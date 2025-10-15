terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

# ТОЛЬКО Kubernetes кластер - используем существующие сети
resource "yandex_kubernetes_cluster" "devops_cluster" {
  name        = "devops-cluster"
  description = "Kubernetes cluster for DevOps project"

  network_id = "enpltiq1jv3q8uegb2v7"  # ID существующей сети

  master {
    version = "1.30"
    zonal {
      zone      = "ru-central1-a"
      subnet_id = "e9b3tv2o8ju89q3u8335"  # ID существующей подсети
    }
    public_ip = true
  }

  service_account_id      = "ajeqma33h59j1iqcnlu6"  # ID существующего service account
  node_service_account_id = "ajeqma33h59j1iqcnlu6"
}

# Node group
resource "yandex_kubernetes_node_group" "devops_nodes" {
  cluster_id = yandex_kubernetes_cluster.devops_cluster.id
  name       = "devops-nodes"

  instance_template {
    platform_id = "standard-v2"
    
    network_interface {
      nat        = true
      subnet_ids = ["e9b3tv2o8ju89q3u8335"]  # ID существующей подсети
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.devops_cluster
  ]
}

output "cluster_external_endpoint" {
  value = yandex_kubernetes_cluster.devops_cluster.master[0].external_v4_endpoint
}
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

# -----------------------------------------------------------------
# 1. Yandex Container Registry (СНАЧАЛА создаем registry)
# -----------------------------------------------------------------
resource "yandex_container_registry" "devops_registry" {
  name = "devops-project-registry"
}

# -----------------------------------------------------------------
# 2. Kubernetes Cluster
# -----------------------------------------------------------------
resource "yandex_kubernetes_cluster" "devops_cluster" {
  name        = "devops-cluster"
  description = "Kubernetes cluster for DevOps project"

  network_id = "enpltiq1jv3q8uegb2v7" 

  master {
    version = "1.30"
    zonal {
      zone      = "ru-central1-a"
      subnet_id = "e9b3tv2o8ju89q3u8335" 
    }
    public_ip = true
  }

  service_account_id      = "ajeqma33h59j1iqcnlu6" 
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
      subnet_ids = ["e9b3tv2o8ju89q3u8335"] 
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

# -----------------------------------------------------------------
# 3. Настройка IAM (ПРАВА ДОСТУПА)
# -----------------------------------------------------------------

# 3.1. Создание нового SA для CI/CD (Push Images)
resource "yandex_iam_service_account" "github_ci_sa" {
  name        = "github-ci-sa"
  description = "Service Account for GitHub Actions to push images to YCR"
}

# 3.2. Права для Kubernetes Node Group SA (Pull Images)
resource "yandex_iam_service_account_iam_member" "node_group_registry_puller" {
  service_account_id = "ajeqma33h59j1iqcnlu6"
  role               = "container-registry.images.puller"
  member             = "serviceAccount:${yandex_iam_service_account.github_ci_sa.id}"  # ← ИСПРАВИЛИ!

  depends_on = [
    yandex_container_registry.devops_registry  # ← ДОБАВИЛИ!
  ]
}

# 3.3. Права для CI/CD SA (Push Images)
resource "yandex_iam_service_account_iam_member" "github_ci_registry_editor" {
  service_account_id = yandex_iam_service_account.github_ci_sa.id
  role               = "container-registry.editor"
  member             = "serviceAccount:${yandex_iam_service_account.github_ci_sa.id}"  # ← ИСПРАВИЛИ!

  depends_on = [
    yandex_container_registry.devops_registry  # ← ДОБАВИЛИ!
  ]
}

# -----------------------------------------------------------------
# 4. Outputs
# -----------------------------------------------------------------
output "cluster_external_endpoint" {
  value = yandex_kubernetes_cluster.devops_cluster.master[0].external_v4_endpoint
}

output "registry_id" {
  value = yandex_container_registry.devops_registry.id
}

output "github_ci_sa_id" {
  value = yandex_iam_service_account.github_ci_sa.id
}
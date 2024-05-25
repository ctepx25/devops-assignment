variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "mongo_root_password" {
  type    = string
  default = "redhat"
}

variable "mongo_username" {
  type    = string
  default = "dev"
}

variable "mongo_password" {
  type    = string
  default = "redhat"
}

variable "mongo_db" {
  type    = string
  default = "default"
}

variable "mongo_name" {
  type    = string
  default = "mongodb"
}

variable "node_app_image" {
  type    = string
  nullable = false
}

variable "node_app_chart_path" {
  type    = string
  default = "../k8s/vi-tech-chart-0.1.0.tgz"
}

provider "helm" {
  # Several Kubernetes authentication methods are possible: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kube_config)
}

resource "helm_release" "mongodb" {
  chart      = "mongodb"
  name       = var.mongo_name
  namespace  = var.namespace
  repository = "bitnami"

  #version    = "15.5.3"

  set {
    name  = "auth.rootPassword"
    value = var.mongo_root_password
  }

  set {
    name  = "auth.username"
    value = var.mongo_username
  }

  set {
    name  = "auth.password"
    value = var.mongo_password
  }

  set {
    name  = "auth.database"
    value = var.mongo_db
  }

}


resource "helm_release" "node-app" {
  depends_on = [helm_release.mongodb]
  name       = "node-app"
  chart      = var.node_app_chart_path

  set {
    name = "image"
    value = var.node_app_image
  }
  set {
    name = "mongo_user"
    value = var.mongo_username
  }

  set {
    name = "mongo_pass"
    value = var.mongo_password
  }

  set {
    name = "mongo_hostname"
    value = var.mongo_name
  }

  set {
    name = "mongo_db"
    value = var.mongo_db
  }
}

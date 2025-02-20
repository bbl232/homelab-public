terraform {
  backend "s3" {
    bucket = "tfstate.billv.ca"
    key = "k8s-setup/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "kubernetes" {
    config_path    = "~/.kube/config"
    ignore_annotations = ["metallb\\.universe\\.tf\\/ip\\-allocated\\-from\\-pool"]
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "metallb-system" {
  source = "./metallb-system"
}

module "cert-manager" {
  source = "./cert-manager"
}

module "authentik_system" {
  source = "./authentik-system"
}

module "longhorn_system" {
  source = "./longhorn-system"
}

module "pihole_system" {
  source = "./pihole-system"
}

module "omada_controller" {
  source = "./omada-controller"
}

module "dashboard" {
  source = "./dashboard-system"
}

resource "kubernetes_service_account_v1" "bill" {
  metadata {
    name = "bill"
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "bill"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account_v1.bill.metadata.0.name
  }
}

resource "kubernetes_secret_v1" "bill_token" {
  metadata {
    name = "bill-token"
    annotations = {
      "kubernetes.io/service-account.name": "bill"
    }
  }
  type = "kubernetes.io/service-account-token"
}
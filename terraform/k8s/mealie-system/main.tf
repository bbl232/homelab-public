terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    helm = {
        source = "hashicorp/helm"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "kubernetes_namespace_v1" "mealie" {
  metadata {
    name = "mealie"
  }
}

data "aws_ssm_parameter" "smtp" {
  name = "zoho-smtp-creds"
}

resource "kubernetes_stateful_set_v1" "mealie" {
  metadata {
      name = "mealie"
      namespace = kubernetes_namespace_v1.mealie.metadata.0.name
  }
  spec {
    volume_claim_template {
      metadata {
          name = "mealie-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "longhorn"
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
    selector {
      match_labels = {
        app = "mealie"
      }
    }
    service_name = "mealie"
    template {
      metadata {
        name = "mealie"
        namespace = kubernetes_namespace_v1.mealie.metadata.0.name
        labels = {
          app = "mealie"
        }
      }
      spec {
        host_network = true
        container {
          name = "mealie"
          image = "hkotel/mealie:v2.8.0"
          image_pull_policy = "Always"
          volume_mount {
            name = "mealie-data"
            mount_path = "/app/data"
          }
          port {
            container_port = 9000
            name = "http"
            protocol = "TCP"
          }
          env {
            name = "ALLOW_SIGNUP"
            value = "false"
          }
          env {
            name = "LOG_LEVEL"
            value = "ERROR"
          }
          env {
            name = "DB_ENGINE"
            value = "sqlite"
          }
          env {
            name = "PUID"
            value = "1000"
          }
          env {
            name = "PGID"
            value = "1000"
          }
          env {
            name = "TZ"
            value = "America/Toronto"
          }
          env {
            name = "BASE_URL"
            value = "https://mealie.billv.ca"
          }
          env {
            name = "OIDC_AUTH_ENABLED"
            value = "true"
          }
          env {
            name = "OIDC_CONFIGURATION_URL"
            value = var.OIDC_CONFIGURATION_URL
          }
          env {
            name = "OIDC_CLIENT_ID"
            value = var.OIDC_CLIENT_ID
          }
          env {
            name = "OIDC_CLIENT_SECRET"
            value = var.OIDC_CLIENT_SECRET
          }
          env {
            name = "OIDC_USER_GROUP"
            value = var.OIDC_USER_GROUP
          }
          env {
            name = "OIDC_ADMIN_GROUP"
            value = var.OIDC_ADMIN_GROUP
          }
          env {
            name = "OIDC_PROVIDER_NAME"
            value = var.OIDC_PROVIDER_NAME
          }
          env {
            name = "SMTP_HOST"
            value = "smtp.zoho.com"
          }
          env {
            name = "SMTP_PORT"
            value = "465"
          }
          env {
            name = "SMTP_FROM_EMAIL"
            value = "bill@vandenberk.me"
          }
          env {
            name = "SMTP_AUTH_STRATEGY"
            value = "SSL"
          }
          env {
            name = "SMTP_USER"
            value = "bill@vandenberk.me"
          }
          env {
            name = "SMTP_PASSWORD"
            value = data.aws_ssm_parameter.smtp.value
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mealie" {
  metadata {
    name = "mealie"
    namespace = kubernetes_namespace_v1.mealie.metadata.0.name
  }
  spec {
    selector = {
        "app" = "mealie"
    }
    port {
      name = "http"
      port = 80
      target_port = 9000
      protocol = "TCP"
    }
  }
}

resource "kubernetes_manifest" "certificate_mealie_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "mealie-billv-ca"
      "namespace" = kubernetes_namespace_v1.mealie.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "mealie.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "mealie-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "mealie"
      "namespace" = kubernetes_namespace_v1.mealie.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`mealie.billv.ca`)"
        "services" = [{
          "kind" = "Service"
          "name" = "mealie"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "mealie-billv-ca"
      }
    }
  }
}

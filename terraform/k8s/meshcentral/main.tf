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

resource "kubernetes_namespace_v1" "meshcentral" {
  metadata {
    name = "meshcentral"
  }
}

resource "kubernetes_stateful_set_v1" "meshcentral" {
  metadata {
      name = "meshcentral"
      namespace = kubernetes_namespace_v1.meshcentral.metadata.0.name
  }
  spec {
    volume_claim_template {
      metadata {
          name = "meshcentral-data"
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
    volume_claim_template {
      metadata {
          name = "meshcentral-files"
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
        app = "meshcentral"
      }
    }
    service_name = "meshcentral"
    template {
      metadata {
        name = "meshcentral"
        namespace = kubernetes_namespace_v1.meshcentral.metadata.0.name
        labels = {
          app = "meshcentral"
        }
      }
      spec {
        container {
          name = "meshcentral"
          image = "typhonragewind/meshcentral:1.1.38"
          image_pull_policy = "Always"
          volume_mount {
            name = "meshcentral-data"
            mount_path = "/opt/meshcentral/meshcentral-files"
          }
          volume_mount {
            name = "meshcentral-files"
            mount_path = "/opt/meshcentral/meshcentral-data"
          }
          port {
            container_port = 443
            name = "http"
            protocol = "TCP"
          }
          env {
            name = "HOSTNAME"
            value = "meshcentral.billv.ca"
          }
          env {
            name = "ALLOW_NEW_ACCOUNTS"
            value = "true"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "meshcentral" {
  metadata {
    name = "meshcentral"
    namespace = kubernetes_namespace_v1.meshcentral.metadata.0.name
    annotations = {
      "metallb.universe.tf/loadBalancerIPs" = "10.206.101.4"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
        "app" = "meshcentral"
    }
    port {
      name = "http"
      port = 443
      target_port = 443
      protocol = "TCP"
    }
  }
}

# resource "kubernetes_manifest" "certificate_meshcentral_billv_ca" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind" = "Certificate"
#     "metadata" = {
#       "name" = "meshcentral-billv-ca"
#       "namespace" = kubernetes_namespace_v1.meshcentral.metadata.0.name
#     }
#     "spec" = {
#       "dnsNames" = [
#         "meshcentral.billv.ca",
#       ]
#       "issuerRef" = {
#         "kind" = "ClusterIssuer"
#         "name" = "letsencrypt"
#       }
#       "secretName" = "meshcentral-billv-ca"
#     }
#   }
# }

# resource "kubernetes_manifest" "ingressroute" {
#   manifest = {
#     "apiVersion" = "traefik.containo.us/v1alpha1"
#     "kind" = "IngressRoute"
#     "metadata" = {
#       "name" = "meshcentral"
#       "namespace" = kubernetes_namespace_v1.meshcentral.metadata.0.name
#     }
#     "spec" = {
#       "entryPoints" = ["websecure"]
#       "routes" = [{
#         "kind" = "Rule"
#         "match" = "Host(`meshcentral.billv.ca`)"
#         "services" = [{
#           "kind" = "Service"
#           "name" = "meshcentral"
#           "port" = 443
#           "serversTransport" = "meshcentral"
#           "scheme" = "https"
#         }]
#       }]
#       "tls" = {
#         "secretName" = "meshcentral-billv-ca"
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "servers_transport" {
#   manifest = {
#     "apiVersion" = "traefik.io/v1alpha1"
#     "kind" = "ServersTransport"
#     "metadata" = {
#       "name" = "meshcentral"
#       "namespace" = kubernetes_namespace_v1.meshcentral.metadata.0.name
#     }
#     "spec" = {
#       "serverName" = "meshcentral.${kubernetes_namespace_v1.meshcentral.metadata.0.name}.svc.cluster.local"
#       "insecureSkipVerify" = "true"
#     }
#   }
# }
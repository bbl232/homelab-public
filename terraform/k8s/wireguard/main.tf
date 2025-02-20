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

resource "kubernetes_namespace_v1" "wireguard" {
  metadata {
    name = "wireguard"
  }
}

resource "kubernetes_stateful_set_v1" "wireguard" {
  metadata {
      name = "wireguard"
      namespace = kubernetes_namespace_v1.wireguard.metadata.0.name
  }
  spec {
    volume_claim_template {
      metadata {
          name = "wireguard-data"
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
          name = "wireguard-ui-data"
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
        app = "wireguard"
      }
    }
    service_name = "wireguard"
    template {
      metadata {
        name = "wireguard"
        namespace = kubernetes_namespace_v1.wireguard.metadata.0.name
        labels = {
          app = "wireguard"
        }
      }
      spec {
        security_context {
          sysctl {
            name = "net.ipv4.conf.all.src_valid_mark"
            value = "1"
          }
        }
        container {
          name = "wireguard"
          image = "linuxserver/wireguard:latest"
          image_pull_policy = "Always"
          volume_mount {
            name = "wireguard-data"
            mount_path = "/config/wg_confs"
          }
          port {
            container_port = 51820
            name = "wg"
            protocol = "UDP"
          }
          security_context {
            capabilities {
              add = [ "NET_ADMIN" , "SYS_MODULE" ]
            }
          }
        }
        container {
          name = "wireguard-ui"
          image = "ngoduykhanh/wireguard-ui:latest"
          image_pull_policy = "Always"
          security_context {
            capabilities {
              add = [ "NET_ADMIN" ]
            }
          }
          port {
            container_port = 5000
            name = "http"
            protocol = "TCP"
          }
          volume_mount {
            name = "wireguard-data"
            mount_path = "/etc/wireguard"
          }
          volume_mount {
            name = "wireguard-ui-data"
            mount_path = "/app/db"
          }
          env {
            name = "DISABLE_LOGIN"
            value = "true"
          }
          env {
            name = "WGUI_MANAGE_RESTART"
            value = "true"
          }
          env {
            name = "WGUI_MANAGE_START"
            value = "false"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "wireguard" {
  metadata {
    name = "wireguard"
    namespace = kubernetes_namespace_v1.wireguard.metadata.0.name
    annotations = {
      "metallb.universe.tf/loadBalancerIPs" = "10.206.101.3"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
        "app" = "wireguard"
    }
    port {
      name = "wg"
      port = 51820
      target_port = 51820
      protocol = "UDP"
    }
  }
}

resource "kubernetes_service_v1" "wireguard_ui" {
  metadata {
    name = "wireguard-ui"
    namespace = kubernetes_namespace_v1.wireguard.metadata.0.name
  }
  spec {
    selector = {
        "app" = "wireguard"
    }
    port {
      name = "http"
      port = 5000
      target_port = 5000
      protocol = "TCP"
    }
  }
}

resource "kubernetes_manifest" "certificate_wireguard_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "wireguard-billv-ca"
      "namespace" = kubernetes_namespace_v1.wireguard.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "wireguard.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "wireguard-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "wireguard"
      "namespace" = kubernetes_namespace_v1.wireguard.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`wireguard.billv.ca`)"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = "wireguard"
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "wireguard-ui"
          "port" = 5000
        }]
      }]
      "tls" = {
        "secretName" = "wireguard-billv-ca"
      }
    }
  }
}

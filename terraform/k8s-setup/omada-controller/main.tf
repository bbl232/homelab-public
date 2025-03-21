terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace_v1" "omada_controller" {
  metadata {
    name = "omada-controller"
  }
}

resource "kubernetes_stateful_set_v1" "omada" {
  metadata {
      name = "omada-controller"
      namespace = kubernetes_namespace_v1.omada_controller.metadata.0.name
  }
  spec {
    volume_claim_template {
      metadata {
          name = "omada-logs"
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
          name = "omada-data"
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
        app = "omada-controller"
      }
    }
    service_name = "omada-controller"
    template {
      metadata {
        name = "omada-controller"
        namespace = kubernetes_namespace_v1.omada_controller.metadata.0.name
        labels = {
          app = "omada-controller"
        }
      }
      spec {
        host_network = true
        container {
          name = "omada-controller"
          image = "mbentley/omada-controller:5.15"
          image_pull_policy = "Always"
          volume_mount {
            name = "omada-data"
            mount_path = "/opt/tplink/EAPController/data"
          }
          volume_mount {
            name = "omada-logs"
            mount_path = "/opt/tplink/EAPController/logs"
          }
          port {
            name = "http"
            container_port = 8080
            protocol = "TCP"
          }
          port {
            name = "https"
            container_port = 8043
            protocol = "TCP"
          }
          port {
            name = "app-discovery"
            protocol = "TCP"
            container_port = 27001
          }
          port {
            name = "upgrade-v1"
            protocol = "TCP"
            container_port = 29813
          }
          port {
            name = "manager-v1"
            protocol = "TCP"
            container_port = 29811
          }
          port {
            name = "manager-v2"
            protocol = "TCP"
            container_port = 29814
          }
          port {
            name = "discovery"
            protocol = "UDP"
            container_port = 29810
          }
          port {
            name = "discovery2"
            protocol = "UDP"
            container_port = 19810
          }
          port {
            name = "transfer-v2"
            protocol = "TCP"
            container_port = 29815
          }
          port {
            name = "rtty"
            protocol = "TCP"
            container_port = 29816
          }
          env {
            name = "PUID"
            value = "508"
          }
          env {
            name = "PGID"
            value = "508"
          }
          env {
            name = "MANAGE_HTTP_PORT"
            value = "8080"
          }
          env {
            name = "MANAGE_HTTPS_PORT"
            value = "8043"
          }
          env {
            name = "PORTAL_HTTP_PORT"
            value = "8080"
          }
          env {
            name = "PORTAL_HTTPS_PORT"
            value = "8043"
          }
          env {
            name = "PORTAL_APP_DISCOVERY"
            value = "27001"
          }
          env {
            name = "PORT_ADOPT_V1"
            value = "29812"
          }
          env {
            name = "PORT_UPGRADE_V1"
            value = "29813"
          }
          env {
            name = "PORT_MANAGER_V1"
            value = "29811"
          }
          env {
            name = "PORT_MANAGER_V2"
            value = "29814"
          }
          env {
            name = "PORT_DISCOVERY"
            value = "29810"
          }
          env {
            name = "PORT_TRANSFER_V2"
            value = "29815"
          }
          env {
            name = "PORT_RTTY"
            value = "29816"
          }
          env {
            name = "SHOW_SERVER_LOGS"
            value = "true"
          }
          env {
            name = "SHOW_MONGODB_LOGS"
            value = "false"
          }
          env {
            name = "SSL_CERT_NAME"
            value = "tls.crt"
          }
          env {
            name = "SSL_KEY_NAME"
            value = "tls.key"
          }
          env {
            name = "TZ"
            value = "Etc/UTC"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "omada_controller" {
  metadata {
    name = "omada-controller"
    namespace = kubernetes_namespace_v1.omada_controller.metadata.0.name
    annotations = {
      "metallb.universe.tf/loadBalancerIPs" = "10.206.101.2"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
        "app" = "omada-controller"
    }
    port {
      name = "http"
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }
    port {
      name = "https"
      port = 8043
      target_port = 8043
      protocol = "TCP"
    }
    port {
      name = "app-discovery"
      protocol = "TCP"
      port = 27001
      target_port = 27001
    }
    port {
      name = "upgrade-v1"
      protocol = "TCP"
      port = 29813
      target_port = 29813
    }
    port {
      name = "manager-v1"
      protocol = "TCP"
      port = 29811
      target_port = 29811
    }
    port {
      name = "adopt"
      protocol = "TCP"
      port = 29812
      target_port = 29812
    }
    port {
      name = "manager-v2"
      protocol = "TCP"
      port = 29814
      target_port = 29814
    }
    port {
      name = "discovery"
      protocol = "UDP"
      port = 29810
      target_port = 29810
    }
    port {
      name = "discovery2"
      protocol = "UDP"
      port = 19810
      target_port = 19810
    }
    port {
      name = "transfer-v2"
      protocol = "TCP"
      port = 29815
      target_port = 29815
    }
    port {
      name = "rtty"
      protocol = "TCP"
      port = 29816
      target_port = 29816
    }
  }
}

resource "kubernetes_manifest" "certificate_authentik_omada_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "omada-billv-ca"
      "namespace" = kubernetes_namespace_v1.omada_controller.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "omada.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "omada-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "omada"
      "namespace" = kubernetes_namespace_v1.omada_controller.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`omada.billv.ca`)"
        "services" = [{
          "kind" = "Service"
          "name" = "omada-controller"
          "serversTransport" = "omada"
          "port" = 8043
          "scheme" = "https"
        }]
      }]
      "tls" = {
        "secretName" = "omada-billv-ca"
      }
    }
  }
}

resource "kubernetes_manifest" "servers_transport" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "ServersTransport"
    "metadata" = {
      "name" = "omada"
      "namespace" = kubernetes_namespace_v1.omada_controller.metadata.0.name
    }
    "spec" = {
      "serverName" = "omada-controller.${kubernetes_namespace_v1.omada_controller.metadata.0.name}.svc.cluster.local"
      "insecureSkipVerify" = "true"
    }
  }
}

# apiVersion: traefik.io/v1alpha1
# kind: ServersTransport
# metadata:
#   name: mytransport
#   namespace: default

# spec:
#   serverName: foobar                        # [1]
#   insecureSkipVerify: true                  # [2]
#   rootCAsSecrets:                           # [3]
#     - foobar
#     - foobar
#   certificatesSecrets:                      # [4]
#     - foobar
#     - foobar
#   maxIdleConnsPerHost: 1                    # [5]
#   forwardingTimeouts:                       # [6]
#     dialTimeout: 42s                        # [7]
#     responseHeaderTimeout: 42s              # [8]
#     idleConnTimeout: 42s                    # [9]
#   peerCertURI: foobar                       # [10]
#   disableHTTP2: true                        # [11]
#   spiffe:                                   # [12] 
#     ids:                                    # [13]
#     - spiffe://trust-domain/id1
#     - spiffe://trust-domain/id2
#     trustDomain: "spiffe://trust-domain"    # [14]
terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace_v1" "ocis" {
  metadata {
    name = "ocis"
  }
}

resource "kubernetes_config_map_v1" "config" {
  metadata {
    name = "ocis-config"
    namespace = kubernetes_namespace_v1.ocis.metadata.0.name
  }
  data = {
    "proxy.yaml" = <<EOF
role_assignment:
    driver: oidc
    oidc_role_mapper:
        role_claim: groups
        role_mapping:
            - role_name: admin
              claim_value: ocis_Admins
            - role_name: spaceadmin
              claim_value: ocis_Space_Admins
            - role_name: user
              claim_value: ocis_Users
            - role_name: guest
              claim_value: ocis_Guests
role_quotas:
  71881883-1768-46bd-a24d-a356a2afdf7f: 10000000000
  d7beeea8-8ff4-406b-8fb6-ab2dd81e6b11: 5000000000
EOF
    "csp.yaml" = <<EOF
directives:
  child-src:
    - '''self'''
  connect-src:
    - '''self'''
    - 'blob:'
    - 'https://raw.githubusercontent.com/owncloud/awesome-ocis/'
    # In contrary to bash and docker the default is given after the | character
    - 'https://auth.billv.ca/'
  default-src:
    - '''none'''
  font-src:
    - '''self'''
  frame-ancestors:
    - '''none'''
  frame-src:
    - '''self'''
    - 'blob:'
    - 'https://embed.diagrams.net/'
  img-src:
    - '''self'''
    - 'data:'
    - 'blob:'
    - 'https://raw.githubusercontent.com/owncloud/awesome-ocis/'
  manifest-src:
    - '''self'''
  media-src:
    - '''self'''
  object-src:
    - '''self'''
    - 'blob:'
  script-src:
    - '''self'''
    - '''unsafe-inline'''
  style-src:
    - '''self'''
    - '''unsafe-inline'''
EOF
  }
}

resource "kubernetes_stateful_set_v1" "ocis" {
  metadata {
      name = "ocis"
      namespace = kubernetes_namespace_v1.ocis.metadata.0.name
  }
  spec {
    volume_claim_template {
      metadata {
          name = "ocis-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "longhorn"
        resources {
          requests = {
            storage = "30Gi"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
          name = "ocis-config"
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
        app = "ocis"
      }
    }
    service_name = "ocis"
    template {
      metadata {
        name = "ocis"
        namespace = kubernetes_namespace_v1.ocis.metadata.0.name
        labels = {
          app = "ocis"
        }
      }
      spec {
        init_container {
          name = "init-chown"
          command = ["/bin/sh", "-c", "if [ ! -f \"/etc/ocis/proxy.yaml\" ]; then cp /etc/ocis-config/proxy.yaml /etc/ocis/proxy.yaml && chown -R 1000:1000 /etc/ocis && chown -R 1000:1000 /var/lib/ocis; fi"]
          image = "busybox:stable"
          image_pull_policy = "IfNotPresent"
          security_context {
            run_as_non_root = false
            run_as_user = 0
          }
          volume_mount {
            name = "ocis-data"
            mount_path = "/var/lib/ocis"
          }
          volume_mount {
            name = "ocis-config"
            mount_path = "/etc/ocis"
          }
          volume_mount {
            name = "ocis-configmap"
            mount_path = "/etc/ocis-config"
          }
        }
        volume {
          name = "ocis-configmap"
          config_map {
            name = kubernetes_config_map_v1.config.metadata.0.name
          }
        }
        container {
          name = "ocis"
          image = "owncloud/ocis:7.1"
          command = ["/bin/bash", "-c", "ocis init || true; ocis server"]
          image_pull_policy = "Always"
          security_context {
            run_as_group = 1000
            run_as_user = 1000
            run_as_non_root = true
          }
          volume_mount {
            name = "ocis-data"
            mount_path = "/var/lib/ocis"
          }
          volume_mount {
            name = "ocis-config"
            mount_path = "/etc/ocis"
          }
          volume_mount {
            name = "ocis-configmap"
            mount_path = "/etc/ocis-config"
          }
          port {
            container_port = 9200
            protocol = "TCP"
          }
          env {
            name = "OCIS_URL"
            value = "https://ocis.billv.ca"
          }
          env {
            name = "OCIS_LOG_LEVEL"
            value = "error"
          }
          env {
            name = "OCIS_LOG_COLOR"
            value = "false"
          }
          env {
            name = "PROXY_TLS"
            value = "false"
          }
          env {
            name = "OCIS_INSECURE"
            value = "false"
          }
          env {
            name = "PROXY_AUTOPROVISION_ACCOUNTS"
            value = "true"
          }
          env {
            name = "PROXY_ROLE_ASSIGNMENT_DRIVER"
            value = "oidc"
          }
          env {
            name = "OCIS_OIDC_ISSUER"
            value = var.oidc_url
          }
          env {
            name = "PROXY_OIDC_REWRITE_WELLKNOWN"
            value = "true"
          }
          env {
            name = "WEB_OIDC_CLIENT_ID"
            value = var.client_id
          }
          env {
            name = "PROXY_USER_OIDC_CLAIM"
            value = "preferred_username"
          }
          env {
            name = "PROXY_USER_CS3_CLAIM"
            value = "username"
          }
          env {
            name = "OCIS_EXCLUDE_RUN_SERVICES"
            value = "idp"
          }
          env {
            name = "PROXY_CSP_CONFIG_FILE_LOCATION"
            value = "/etc/ocis-config/csp.yaml"
          }
          env {
            name = "OCIS_ADMIN_USER_ID"
            value = ""
          }
          env {
            name = "PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD"
            value = "none"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "ocis" {
  metadata {
    name = "ocis"
    namespace = kubernetes_namespace_v1.ocis.metadata.0.name
  }
  spec {
    selector = {
        "app" = "ocis"
    }
    port {
      name = "http"
      port = 80
      target_port = 9200
      protocol = "TCP"
    }
  }
}

resource "kubernetes_manifest" "certificate_ocis_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "ocis-billv-ca"
      "namespace" = kubernetes_namespace_v1.ocis.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "ocis.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "ocis-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "ocis"
      "namespace" = kubernetes_namespace_v1.ocis.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`ocis.billv.ca`)"
        "services" = [{
          "kind" = "Service"
          "name" = "ocis"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "ocis-billv-ca"
      }
    }
  }
}


# services:
#   ocis:
#     image: ${OCIS_DOCKER_IMAGE:-owncloud/ocis}:${OCIS_DOCKER_TAG:-latest}
#     networks:
#       ocis-net:
#     entrypoint:
#       - /bin/sh
#     # run ocis init to initialize a configuration file with random secrets
#     # it will fail on subsequent runs, because the config file already exists
#     # therefore we ignore the error and then start the ocis server
#     command: ["-c", "ocis init || true; ocis server"]
#     environment:
#       # Keycloak IDP specific configuration
#       PROXY_AUTOPROVISION_ACCOUNTS: "true"
#       PROXY_ROLE_ASSIGNMENT_DRIVER: "oidc"
#       OCIS_OIDC_ISSUER: https://${KEYCLOAK_DOMAIN:-keycloak.owncloud.test}/realms/${KEYCLOAK_REALM:-oCIS}
#       PROXY_OIDC_REWRITE_WELLKNOWN: "true"
#       WEB_OIDC_CLIENT_ID: ${OCIS_OIDC_CLIENT_ID:-web}
#       # general config
#       OCIS_URL: https://${OCIS_DOMAIN:-ocis.owncloud.test}
#       OCIS_LOG_LEVEL: ${OCIS_LOG_LEVEL:-info}
#       OCIS_LOG_COLOR: "${OCIS_LOG_COLOR:-false}"
#       PROXY_TLS: "false" # do not use SSL between Traefik and oCIS
#       PROXY_USER_OIDC_CLAIM: "preferred_username"
#       PROXY_USER_CS3_CLAIM: "username"
#       # INSECURE: needed if oCIS / Traefik is using self generated certificates
#       OCIS_INSECURE: "${INSECURE:-false}"
#       OCIS_ADMIN_USER_ID: ""
#       OCIS_EXCLUDE_RUN_SERVICES: "idp"
#       GRAPH_ASSIGN_DEFAULT_USER_ROLE: "false"
#       GRAPH_USERNAME_MATCH: "none"
#       # password policies
#       OCIS_PASSWORD_POLICY_BANNED_PASSWORDS_LIST: "banned-password-list.txt"
#       PROXY_CSP_CONFIG_FILE_LOCATION: /etc/ocis/csp.yaml
#       KEYCLOAK_DOMAIN: ${KEYCLOAK_DOMAIN:-keycloak.owncloud.test}
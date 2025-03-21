terraform {
  required_providers {
    helm = {
        source = "hashicorp/helm"
    }
    random = {
        source = "hashicorp/random"
    }
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
  }
}

data "aws_ssm_parameter" "smtp" {
  name = "zoho-smtp-creds"
}

resource "random_password" "postgresql_password" {
    length = 20
    special = true
}

resource "random_password" "authentik_secret_key" {
    length = 20
    special = true
}

resource "random_password" "akadmin_api_key" {
  length = 20
  special = true
}

resource "random_password" "akadmin_password" {
  length = 20
  special = true
}

resource "helm_release" "authentik" {
  name = "authentik"
  repository = "https://charts.goauthentik.io"
  chart = "authentik"
  version = "2025.2.2"
  namespace = "authentik"
  create_namespace = true
  values = [
<<-EOF
authentik:
    secret_key: ${random_password.authentik_secret_key.result}
    error_reporting:
        enabled: true
    postgresql:
        password: ${random_password.postgresql_password.result}
    email:
      host: "smtp.zoho.com"
      port: 465
      username: "bill@vandenberk.me"
      password: "${data.aws_ssm_parameter.smtp.value}"
      use_tls: false
      use_ssl: true
      timeout: 10
      from: "Authentik <bill@vandenberk.me>"

server:
    ingress:
        enabled: false

postgresql:
    enabled: true
    auth:
        password: ${random_password.postgresql_password.result}
    primary:
      persistence:
        storageClass: longhorn
redis:
    enabled: true
    primary:
      persistence:
        storageClass: longhorn


worker:
    env:
        - name: AUTHENTIK_BOOTSTRAP_PASSWORD
          value: ${random_password.akadmin_password.result}
        - name: AUTHENTIK_BOOTSTRAP_EMAIL
          value: bill@vandenberk.me
        - name: AUTHENTIK_BOOTSTRAP_TOKEN
          value: ${random_password.akadmin_api_key.result}
EOF
  ]
}

data "kubernetes_service_v1" "authentik_server" {
    depends_on = [ helm_release.authentik ]
    metadata {
      namespace = "authentik"
      name = "authentik-server"
    }
}

resource "kubernetes_manifest" "certificate_authentik_star_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "star-billv-ca"
      "namespace" = "authentik"
    }
    "spec" = {
      "dnsNames" = [
        "*.billv.ca",
        "billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "star-billv-ca"
    }
  }
}


resource "kubernetes_manifest" "certificate_authentik_auth_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "auth-billv-ca"
      "namespace" = "authentik"
    }
    "spec" = {
      "dnsNames" = [
        "auth.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "auth-billv-ca"
    }
  }
}


resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "auth"
      "namespace" = "authentik"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`auth.billv.ca`)"
        "services" = [{
          "kind" = "Service"
          "name" = "authentik-server"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "auth-billv-ca"
      }
    }
  }
}
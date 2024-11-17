terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    helm = {
        source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace_v1" "kube_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kube-dashboard" {
  name = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart = "kubernetes-dashboard"

  namespace = kubernetes_namespace_v1.kube_dashboard.metadata.0.name
  create_namespace = false
  values = [
<<-EOF
EOF
  ]
}

resource "kubernetes_manifest" "certificate_kube_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "kube-billv-ca"
      "namespace" = kubernetes_namespace_v1.kube_dashboard.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "kube.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "kube-billv-ca"
    }
  }
}


resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "kube"
      "namespace" = kubernetes_namespace_v1.kube_dashboard.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`kube.billv.ca`)"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = kubernetes_namespace_v1.kube_dashboard.metadata.0.name
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "kubernetes-dashboard-kong-proxy"
          "serversTransport" = "kube"
          "port" = 443
          "scheme" = "https"
        }]
      }]
      "tls" = {
        "secretName" = "kube-billv-ca"
      }
    }
  }
}

resource "kubernetes_manifest" "servers_transport" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "ServersTransport"
    "metadata" = {
      "name" = "kube"
      "namespace" = kubernetes_namespace_v1.kube_dashboard.metadata.0.name
    }
    "spec" = {
      "serverName" = "kubernetes-dashboard-kong-proxy.${kubernetes_namespace_v1.kube_dashboard.metadata.0.name}.svc.cluster.local"
      "insecureSkipVerify" = "true"
    }
  }
}
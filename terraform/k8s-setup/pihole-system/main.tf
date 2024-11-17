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

data "kubernetes_service_v1" "traefik" {
  metadata {
    name = "traefik"
    namespace = "kube-system"
  }
}

resource "helm_release" "pihole" {
  name = "pihole"
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart = "pihole"
  version = "2.26.2"
  namespace = "pihole-system"
  create_namespace = true
  values = [
<<-EOF
admin:
  enabled: false

replicaCount: 2
serviceWeb:
  https:
    enabled: false

serviceDns:
  type: LoadBalancer
  annotations:
    metallb.universe.tf/loadBalancerIPs: 10.206.101.1
    metallb.universe.tf/allow-shared-ip: pihole-svc

serviceDhcp:
  enabled: false

persistentVolumeClaim:
  enabled: false

dnsmasq:
  customDnsEntries:
    - address=/pihole.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/auth.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/longhorn.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/mealie.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/omada.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/wireguard.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/kube.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/ocis.billv.ca/${data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip}
    - address=/meshcentral.billv.ca/10.206.101.4
EOF
  ]
}

resource "kubernetes_manifest" "certificate_authentik_star_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "pihole-billv-ca"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "dnsNames" = [
        "pihole.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "pihole-billv-ca"
    }
  }
}


resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "pihole"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`pihole.billv.ca`)"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = "pihole-system"
        },{
          "name" = "add-admin"
          "namespace" = "pihole-system"
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "pihole-web"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "pihole-billv-ca"
      }
    }
  }
}
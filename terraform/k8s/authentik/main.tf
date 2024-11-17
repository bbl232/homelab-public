terraform {
  required_providers {
    authentik = {
        source = "goauthentik/authentik"
    }
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  traefik_outpost_name = "traefik-outpost"
}

data "kubernetes_secret_v1" "star_billv_ca" {
    metadata {
        name = "star-billv-ca"
        namespace = "authentik"
    }
}

data "kubernetes_secret_v1" "bill_token" {
    metadata {
        name = "bill-token"
        namespace = "default"
    }
}

resource "authentik_certificate_key_pair" "cert_manager" {
  name             = "star-billv-ca"
  certificate_data = data.kubernetes_secret_v1.star_billv_ca.data["tls.crt"]
  key_data         = data.kubernetes_secret_v1.star_billv_ca.data["tls.key"]
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

resource "authentik_group" "grafana_admins" {
    name = "Grafana Admins"
}

resource "authentik_group" "grafana_users" {
    name = "Grafana Users"
}

resource "authentik_group" "owncloud_users" {
  name = "Owncloud Users"
}

resource "authentik_group" "traefik_admins" {
    name = "Traefik Services Admin"
}

resource "authentik_group" "zoho_users" {
   name = "Zoho Users"
}

resource "random_password" "bill_pw" {
  special = true
  length = 20
}

module "aws" {
  source = "./aws"
}

module "kube_dashboard" {
  source = "./kube-dashboard"
  outpost_name = local.traefik_outpost_name
}

module "proxmox" {
  source = "./proxmox"
  signing_key = authentik_certificate_key_pair.cert_manager.id
}

module "mealie" {
  source = "./mealie"
  signing_key = authentik_certificate_key_pair.cert_manager.id
}

module "ocis" {
  source = "./ocis"
  signing_key = authentik_certificate_key_pair.cert_manager.id
}

module "pihole" {
  source = "./pihole"
  outpost_name = local.traefik_outpost_name
}

module "longhorn" {
  source = "./longhorn"
  outpost_name = local.traefik_outpost_name
}

module "wireguard" {
  source = "./wireguard"
  outpost_name = local.traefik_outpost_name
}

resource "authentik_user" "bill" {
  username = "bill"
  email = "bill@vandenberk.me"
  name = "Bill Vandenberk"
  attributes = jsonencode({
    kube_token = data.kubernetes_secret_v1.bill_token.data["token"]
  })
  password = random_password.bill_pw.result
  groups = [data.authentik_group.admins.id,
            module.aws.admins_group_id,
            module.proxmox.users_group_id, 
            module.pihole.admins_group_id,
            module.longhorn.admins_group_id,
            module.wireguard.admins_group_id,
            module.mealie.admins_group_id,
            module.ocis.admins_group_id,
            module.kube_dashboard.admins_group_id,
            authentik_group.grafana_admins.id, 
            authentik_group.owncloud_users.id, 
            authentik_group.traefik_admins.id, 
            authentik_group.zoho_users.id]
}

resource "authentik_user" "trina" {
  username = "trina"
  email = "trina@vandenberk.me"
  name = "Trina Vandenberk"
  groups = [module.mealie.users_group_id, 
            authentik_group.zoho_users.id,
            module.ocis.users_group_id]
}

resource "authentik_service_connection_kubernetes" "local" {
  name  = "local K3S"
  local = true
}

resource "authentik_outpost" "traefik" {
  name = local.traefik_outpost_name
  protocol_providers = [
    module.pihole.provider_id,
    module.wireguard.provider_id,
    module.kube_dashboard.provider_id,
    module.longhorn.provider_id
  ]
  service_connection = authentik_service_connection_kubernetes.local.id
}
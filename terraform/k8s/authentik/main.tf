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

resource "authentik_group" "zoho_users" {
   name = "Zoho Users"
}

resource "random_password" "bill_pw" {
  special = true
  length = 20
}

resource "random_password" "trina_pw" {
  special = true
  length = 20
}

module "aws" {
  source = "./aws"
}

resource "authentik_property_mapping_provider_scope" "kube_token" {
  name       = "kubetoken"
  scope_name = "kubetoken"
  expression = <<EOF
return {
    "ak_proxy": {
        "user_attributes": {
            "additionalHeaders": {
                "Authorization": "Bearer " + request.user.attributes.get("kube_token", "")
            }
        }
    }
}
EOF
}

module "kube_dashboard" {
  source = "./modules/forwardauth_bundle"
  outpost_name = local.traefik_outpost_name
  app_name = "Kubernetes Dashboard"
  app_slug = "kube-dashboard"
  app_icon = "https://static-00.iconduck.com/assets.00/kubernetes-icon-2048x1995-r1q3f8n7.png"
  app_external_host = "https://kube.billv.ca"
  app_namespace = "kubernetes-dashboard"
  additional_auth_response_headers = ["Authorization"]
  additional_property_mapping_ids = [authentik_property_mapping_provider_scope.kube_token.id]
}

module "proxmox" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "Proxmox"
  app_slug = "proxmox"
  client_id = "proxmox"
  app_launch_url = "https://proxmox.billv.ca"
  app_icon = "https://camo.githubusercontent.com/4e9e0bf3fcd09d6557b4eaa8f790ec17599ed6e8eb37a7e78adaa30650c8a6e3/68747470733a2f2f7777772e70726f786d6f782e636f6d2f696d616765732f70726f786d6f782f50726f786d6f785f73796d626f6c5f7374616e646172645f6865782e706e67"
  allowed_redirect_uris = [{
      matching_mode = "regex",
      url           = "https://10.206.0.2:8006.*",
    },
    {
      matching_mode = "regex",
      url           = "https://10.206.0.3:8006.*",
    },
    {
      matching_mode = "regex",
      url           = "https://10.206.0.4:8006.*",
    },
    {
      matching_mode = "regex",
      url           = "https://proxmox.billv.ca.*",
    }]
}

module "mealie" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "Mealie"
  app_slug = "mealie"
  app_icon = "https://getumbrel.github.io/umbrel-apps-gallery/mealie/icon.svg"
  app_launch_url = "https://mealie.billv.ca"
  allowed_redirect_uris = [{
      matching_mode = "regex",
      url           = "https://mealie.billv.ca/.*",
  }]
}

module "ocis" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "ocis"
  app_slug = "ocis"
  app_icon = "https://static-00.iconduck.com/assets.00/owncloud-icon-2048x2048-uuor4edn.png"
  app_launch_url = "https://ocis.billv.ca"
  client_type = "public"
  oauth_scopes = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
  allowed_redirect_uris = [{
    matching_mode = "regex",
    url           = "https://ocis.billv.ca/.*",
  }]
}

module "ocis-desktop" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "ownCloud-Desktop-OIDC"
  app_slug = "ocis-desktop"
  app_icon = "https://static-00.iconduck.com/assets.00/owncloud-icon-2048x2048-uuor4edn.png"
  app_launch_url = "blank://blank"
  client_id = "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69"
  client_secret = "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh"
  oauth_scopes = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
  allowed_redirect_uris = [{
    matching_mode = "regex",
    url           = "http://127.0.0.1(:.*)?",
  },
  {
    matching_mode = "regex",
    url           = "http://localhost(:.*)?",
  }]
}

module "ocis-iOS" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "ownCloud-iOS-OIDC"
  app_slug = "ocis-ios"
  app_icon = "https://static-00.iconduck.com/assets.00/owncloud-icon-2048x2048-uuor4edn.png"
  app_launch_url = "blank://blank"
  client_id = "mxd5OQDk6es5LzOzRvidJNfXLUZS2oN3oUFeXPP8LpPrhx3UroJFduGEYIBOxkY1"
  client_secret = "KFeFWWEZO9TkisIQzR3fo7hfiMXlOpaqP8CFuTbSHzV1TUuGECglPxpiVKJfOXIx"
  oauth_scopes = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
  allowed_redirect_uris = [{
    matching_mode = "strict",
    url           = "oc://ios.owncloud.com",
  },
  {
    matching_mode = "strict",
    url           = "oc.ios://ios.owncloud.com",
  }]
}

module "ocis-android" {
  source = "./modules/oidc_bundle"
  signing_key = authentik_certificate_key_pair.cert_manager.id
  app_name = "ownCloud-Android-OIDC"
  app_slug = "ocis-android"
  app_icon = "https://static-00.iconduck.com/assets.00/owncloud-icon-2048x2048-uuor4edn.png"
  app_launch_url = "blank://blank"
  client_id = "e4rAsNUSIUs0lF4nbv9FmCeUkTlV9GdgTLDH1b5uie7syb90SzEVrbN7HIpmWJeD"
  client_secret = "dInFYGV33xKzhbRmpqQltYNdfLdJIfJ9L5ISoKhNoT9qZftpdWSP71VrpGR9pmoD"
  oauth_scopes = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
  allowed_redirect_uris = [{
    matching_mode = "strict",
    url           = "oc://android.owncloud.com",
  }]
}

module "pihole" {
  source = "./modules/forwardauth_bundle"
  app_name = "Pi Hole"
  app_slug = "pihole"
  app_external_host = "https://pihole.billv.ca"
  app_namespace = "pihole-system"
  app_icon = "https://upload.wikimedia.org/wikipedia/commons/0/00/Pi-hole_Logo.png?20180925041558"
  outpost_name = local.traefik_outpost_name
}

module "longhorn" {
  source = "./modules/forwardauth_bundle"
  app_name = "longhorn"
  app_slug = "longhorn"
  app_external_host = "https://longhorn.billv.ca"
  app_icon = "https://raw.githubusercontent.com/longhorn/website/refs/heads/master/static/img/logos/longhorn-icon-color.png"
  app_namespace = "longhorn-system"
  outpost_name = local.traefik_outpost_name
}

module "wireguard" {
  source = "./modules/forwardauth_bundle"
  app_icon = "https://static-00.iconduck.com/assets.00/wireguard-icon-1024x1024-78n6jncy.png"
  app_name = "Wireguard"
  app_slug = "wireguard"
  app_external_host = "https://wireguard.billv.ca"
  app_namespace = "wireguard"
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
            module.pihole.access_group_id,
            module.longhorn.access_group_id,
            module.wireguard.access_group_id,
            module.mealie.admins_group_id,
            module.ocis.admins_group_id,
            module.ocis-desktop.admins_group_id,
            module.ocis-iOS.admins_group_id,
            module.ocis-android.admins_group_id,
            module.kube_dashboard.access_group_id,
            authentik_group.zoho_users.id]
}

resource "authentik_user" "trina" {
  username = "trina"
  email = "trina@vandenberk.me"
  name = "Trina Vandenberk"
  password = random_password.trina_pw.result
  groups = [module.mealie.users_group_id, 
            authentik_group.zoho_users.id,
            module.ocis.users_group_id,
            module.ocis-desktop.users_group_id,
            module.ocis-iOS.users_group_id,
            module.ocis-android.users_group_id]
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
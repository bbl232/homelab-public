terraform {
  required_providers {
    authentik = {
        source = "goauthentik/authentik"
    }
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
  }
}

resource "authentik_group" "proxmox_users" {
    name = "Proxmox Users"
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "scope" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

resource "authentik_provider_oauth2" "proxmox" {
  name      = "proxmox"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = "proxmox"
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = [
    {
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
    }
  ]
}

resource "authentik_application" "proxmox" {
    slug = "proxmox"
    protocol_provider = authentik_provider_oauth2.proxmox.id
    name = "Proxmox"
    group = "Home Services"
    meta_launch_url = "https://proxmox.billv.ca"
    meta_icon = "https://camo.githubusercontent.com/4e9e0bf3fcd09d6557b4eaa8f790ec17599ed6e8eb37a7e78adaa30650c8a6e3/68747470733a2f2f7777772e70726f786d6f782e636f6d2f696d616765732f70726f786d6f782f50726f786d6f785f73796d626f6c5f7374616e646172645f6865782e706e67"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.proxmox.uuid
  group  = authentik_group.proxmox_users.id
  order  = 0
}
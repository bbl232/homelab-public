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

resource "authentik_group" "mealie_users" {
    name = "Mealie_Users"
}

resource "authentik_group" "mealie_admins" {
    name = "Mealie_Admins"
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

resource "random_password" "client_id" {
  length = 20
}

resource "authentik_provider_oauth2" "mealie" {
  name      = "mealie"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = random_password.client_id.result
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = [
    {
      matching_mode = "regex",
      url           = "https://mealie.billv.ca/.*",
    }
  ]
}

resource "authentik_application" "mealie" {
    slug = "mealie"
    protocol_provider = authentik_provider_oauth2.mealie.id
    name = "Mealie"
    group = "Home Services"
    meta_launch_url = "https://mealie.billv.ca"
    meta_icon = "https://getumbrel.github.io/umbrel-apps-gallery/mealie/icon.svg"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.mealie.uuid
  group  = authentik_group.mealie_users.id
  order  = 0
}

resource "authentik_policy_binding" "admin-app-access" {
  target = authentik_application.mealie.uuid
  group  = authentik_group.mealie_admins.id
  order  = 0
}
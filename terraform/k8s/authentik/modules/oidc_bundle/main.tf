terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.12.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"
    }
  }
}

resource "authentik_group" "app_users" {
    name = "${var.app_name}_Users"
}

resource "authentik_group" "app_admins" {
    name = "${var.app_name}_Admins"
}

data "authentik_flow" "default_authorization_flow" {
  slug = var.authorization_flow
}

data "authentik_flow" "default_invalidation_flow" {
  slug = var.invalidation_flow
}

data "authentik_property_mapping_provider_scope" "scope" {
  managed_list = var.oauth_scopes
}

resource "random_password" "client_id" {
  length = 20
  special = false
}

resource "random_password" "client_secret" {
  length = 40
  special = var.client_secret_special
}

resource "authentik_provider_oauth2" "app" {
  name      = var.app_slug
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = coalesce(var.client_id, random_password.client_id.result)
  client_secret = coalesce(var.client_secret, random_password.client_secret.result)
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = var.allowed_redirect_uris
  client_type = var.client_type
  access_token_validity = var.access_token_validity
}

resource "authentik_application" "app" {
    slug = var.app_slug
    protocol_provider = authentik_provider_oauth2.app.id
    name = var.app_name
    group = var.app_group
    meta_launch_url = var.app_launch_url
    meta_icon = var.app_icon
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.app.uuid
  group  = authentik_group.app_users.id
  order  = 0
}

resource "authentik_policy_binding" "admin-app-access" {
  target = authentik_application.app.uuid
  group  = authentik_group.app_admins.id
  order  = 0
}
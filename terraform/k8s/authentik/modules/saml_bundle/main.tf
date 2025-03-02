terraform {
  required_providers {
    authentik = {
        source = "goauthentik/authentik"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "authentik_group" "app_users" {
    name = "${var.app_name}_Users"
    attributes = var.app_group_attributes
}

data "authentik_flow" "default_authorization_flow" {
  slug = var.authorization_flow
}

data "authentik_flow" "default_invalidation_flow" {
  slug = var.invalidation_flow
}

data "authentik_certificate_key_pair" "cert" {
  name = var.certificate_name
}

data "authentik_property_mapping_provider_saml" "property_mappings" {
  managed_list = var.property_mappings
}

resource "authentik_provider_saml" "provider" {
    acs_url = var.acs_url
    name = var.app_name
    authorization_flow = data.authentik_flow.default_authorization_flow.id
    invalidation_flow = data.authentik_flow.default_invalidation_flow.id
    sp_binding = var.sp_binding
    audience = var.audience
    property_mappings = data.authentik_property_mapping_provider_saml.property_mappings.ids
    signing_kp = data.authentik_certificate_key_pair.cert.id
}

resource "authentik_application" "application" {
    slug = var.app_slug
    protocol_provider = authentik_provider_saml.provider.id
    name = var.app_name
    group = var.app_group
    meta_icon = var.app_icon
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.application.uuid
  group  = authentik_group.app_users.id
  order  = 0
}
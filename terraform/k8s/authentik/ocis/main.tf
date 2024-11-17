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

resource "authentik_group" "ocis_users" {
    name = "Ocis_Users"
}

resource "authentik_group" "ocis_admins" {
    name = "Ocis_Admins"
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
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
}

resource "random_password" "client_id" {
  length = 20
}

resource "authentik_provider_oauth2" "ocis" {
  name      = "ocis"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = random_password.client_id.result
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  client_type = "public"
  allowed_redirect_uris = [
    {
      matching_mode = "regex",
      url           = "https://ocis.billv.ca/.*",
    }
  ]
}

resource "authentik_application" "ocis" {
    slug = "ocis"
    protocol_provider = authentik_provider_oauth2.ocis.id
    name = "ocis"
    group = "Home Services"
    meta_launch_url = "https://ocis.billv.ca"
    meta_icon = "https://static-00.iconduck.com/assets.00/owncloud-icon-2048x2048-uuor4edn.png"
}

resource "authentik_provider_oauth2" "ocis_desktop" {
  name      = "ownCloud-Desktop-OIDC"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69"
  client_secret = "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh"
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = [
    {
      matching_mode = "regex",
      url           = "http://127.0.0.1(:.*)?",
    },
    {
      matching_mode = "regex",
      url           = "http://localhost(:.*)?",
    }
  ]
}

resource "authentik_application" "ocis_desktop" {
    slug = "ocis-desktop"
    protocol_provider = authentik_provider_oauth2.ocis_desktop.id
    name = "ownCloud desktop client"
    meta_launch_url = "blank://blank"
}

resource "authentik_provider_oauth2" "ocis_ios" {
  name      = "ownCloud-iOS-OIDC"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = "mxd5OQDk6es5LzOzRvidJNfXLUZS2oN3oUFeXPP8LpPrhx3UroJFduGEYIBOxkY1"
  client_secret = "KFeFWWEZO9TkisIQzR3fo7hfiMXlOpaqP8CFuTbSHzV1TUuGECglPxpiVKJfOXIx"
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "oc://ios.owncloud.com",
    },
    {
      matching_mode = "strict",
      url           = "oc.ios://ios.owncloud.com",
    }
  ]
}

resource "authentik_application" "ocis_ios" {
    slug = "ocis-ios"
    protocol_provider = authentik_provider_oauth2.ocis_ios.id
    name = "ownCloud iOS app"
    meta_launch_url = "blank://blank"
}

resource "authentik_provider_oauth2" "ocis_android" {
  name      = "ownCloud-Android-OIDC"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  client_id = "e4rAsNUSIUs0lF4nbv9FmCeUkTlV9GdgTLDH1b5uie7syb90SzEVrbN7HIpmWJeD"
  client_secret = "dInFYGV33xKzhbRmpqQltYNdfLdJIfJ9L5ISoKhNoT9qZftpdWSP71VrpGR9pmoD"
  signing_key = var.signing_key
  property_mappings = data.authentik_property_mapping_provider_scope.scope.ids
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "oc://android.owncloud.com",
    }
  ]
}

resource "authentik_application" "ocis_android" {
    slug = "ocis-android"
    protocol_provider = authentik_provider_oauth2.ocis_android.id
    name = "ownCloud Android app"
    meta_launch_url = "blank://blank"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.ocis.uuid
  group  = authentik_group.ocis_users.id
  order  = 1
}

resource "authentik_policy_binding" "admin-app-access" {
  target = authentik_application.ocis.uuid
  group  = authentik_group.ocis_admins.id
  order  = 0
}
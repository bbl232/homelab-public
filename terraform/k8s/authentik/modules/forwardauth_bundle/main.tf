terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.10.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}

data "authentik_flow" "default_authorization_flow" {
  slug = var.authorization_flow
}

data "authentik_flow" "default_invalidation_flow" {
  slug = var.invalidation_flow
}

data "authentik_property_mapping_provider_scope" "scope" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-entitlements",
    "goauthentik.io/providers/proxy/scope-proxy"
  ]
}

resource "authentik_provider_proxy" "app" {
  name               = var.app_slug
  mode               = var.app_mode
  cookie_domain      = var.app_cookie_domain
  external_host      = var.app_external_host
  refresh_token_validity = var.refresh_token_validity
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  property_mappings = concat(data.authentik_property_mapping_provider_scope.scope.ids, var.additional_property_mapping_ids)
}

resource "authentik_group" "app_access" {
    name = "${var.app_name}_access"
}

resource "authentik_application" "app" {
  name              = var.app_name
  slug              = var.app_slug
  protocol_provider = authentik_provider_proxy.app.id
  meta_launch_url   = var.app_external_host
  meta_icon         = var.app_icon
  group             = var.app_group
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.app.uuid
  group  = authentik_group.app_access.id
  order  = 0
}

resource "kubernetes_manifest" "middleware_authentik" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "authentik"
      "namespace" = var.app_namespace
    }
    "spec" = {
      "forwardAuth" = {
        "address" = "http://ak-outpost-${var.outpost_name}.authentik.svc.cluster.local:9000/outpost.goauthentik.io/auth/traefik"
        "authResponseHeaders" = concat([
          "X-authentik-username",
          "X-authentik-groups",
          "X-authentik-email",
          "X-authentik-name",
          "X-authentik-uid",
          "X-authentik-jwt",
          "X-authentik-meta-jwks",
          "X-authentik-meta-outpost",
          "X-authentik-meta-provider",
          "X-authentik-meta-app",
          "X-authentik-meta-version",
        ],var.additional_auth_response_headers)
        "trustForwardHeader" = true
      }
    }
  }
}
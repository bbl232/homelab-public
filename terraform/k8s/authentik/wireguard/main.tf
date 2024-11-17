terraform {
  required_providers {
    authentik = {
        source = "goauthentik/authentik"
    }
  }
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-invalidation-flow"
}

resource "authentik_provider_proxy" "wireguard" {
  name               = "wireguard"
  mode               = "forward_single"
  cookie_domain      = "billv.ca"
  external_host      = "https://wireguard.billv.ca"
  refresh_token_validity = "hours=1"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
}

resource "authentik_group" "wireguard_admins" {
    name = "wireguard"
}

resource "authentik_application" "wireguard" {
  name              = "Wireguard"
  slug              = "wireguard"
  protocol_provider = authentik_provider_proxy.wireguard.id
  meta_launch_url   = "https://wireguard.billv.ca"
  meta_icon         = "https://static-00.iconduck.com/assets.00/wireguard-icon-1024x1024-78n6jncy.png"
  group             = "Home Services"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.wireguard.uuid
  group  = authentik_group.wireguard_admins.id
  order  = 0
}

resource "kubernetes_manifest" "middleware_authentik" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "authentik"
      "namespace" = "wireguard"
    }
    "spec" = {
      "forwardAuth" = {
        "address" = "http://ak-outpost-${var.outpost_name}.authentik.svc.cluster.local:9000/outpost.goauthentik.io/auth/traefik"
        "authResponseHeaders" = [
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
        ]
        "trustForwardHeader" = true
      }
    }
  }
}
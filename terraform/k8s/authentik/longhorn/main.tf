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

resource "authentik_provider_proxy" "longhorn" {
  name               = "longhorn"
  mode               = "forward_single"
  cookie_domain      = "billv.ca"
  external_host      = "https://longhorn.billv.ca"
  refresh_token_validity = "hours=1"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
}

resource "authentik_group" "longhorn_admins" {
    name = "longhorn"
}

resource "authentik_application" "longhorn" {
  name              = "longhorn"
  slug              = "longhorn"
  protocol_provider = authentik_provider_proxy.longhorn.id
  meta_launch_url   = "https://longhorn.billv.ca"
  meta_icon         = "https://raw.githubusercontent.com/longhorn/website/refs/heads/master/static/img/logos/longhorn-icon-color.png"
  group             = "Home Services"
}


resource "authentik_policy_binding" "app-access" {
  target = authentik_application.longhorn.uuid
  group  = authentik_group.longhorn_admins.id
  order  = 0
}

resource "kubernetes_manifest" "middleware_authentik" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "authentik"
      "namespace" = "longhorn-system"
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
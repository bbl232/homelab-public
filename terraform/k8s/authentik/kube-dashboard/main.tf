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

data "authentik_property_mapping_provider_scope" "scope" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-entitlements",
    "goauthentik.io/providers/proxy/scope-proxy"
  ]
}

resource "authentik_provider_proxy" "kube" {
  name               = "kube"
  mode               = "forward_single"
  cookie_domain      = "billv.ca"
  external_host      = "https://kube.billv.ca"
  refresh_token_validity = "hours=1"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow = data.authentik_flow.default_invalidation_flow.id
  property_mappings = concat(data.authentik_property_mapping_provider_scope.scope.ids, [authentik_property_mapping_provider_scope.kube_token.id])
}

resource "authentik_group" "admins" {
    name = "Kube Dashboard Users"
}

resource "authentik_application" "kube" {
  name              = "Kubernetes Dashboard"
  slug              = "kube"
  protocol_provider = authentik_provider_proxy.kube.id
  meta_launch_url   = "https://kube.billv.ca"
  meta_icon         = "https://static-00.iconduck.com/assets.00/kubernetes-icon-2048x1995-r1q3f8n7.png"
  group             = "Home Services"
}


resource "authentik_policy_binding" "app-access" {
  target = authentik_application.kube.uuid
  group  = authentik_group.admins.id
  order  = 0
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

resource "kubernetes_manifest" "middleware_authentik" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "authentik"
      "namespace" = "kubernetes-dashboard"
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
          "Authorization"
        ]
        "trustForwardHeader" = true
      }
    }
  }
}
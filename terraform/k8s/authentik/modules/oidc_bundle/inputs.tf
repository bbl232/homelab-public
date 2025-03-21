variable "signing_key" {
  type = string
  description = "Signing key to use for the provider. Should be the ID of the signing key in Authentik."
}

variable "app_name" {
  type = string
  description = "Human friendly application name."
}

variable "app_slug" {
  type = string
  description = "Machine friendly application name."
}

variable "app_launch_url" {
  type = string
  description = "URL used to launch the applicatoin from the User Dashboard."
}

variable "app_icon" {
  type = string
  default = ""
  description = "URL to an icon to assign to the application. (Optional)"
}

variable "client_id" {
  type = string
  default = ""
  description = "Client ID to use for this provider. (Optional)"
}

variable "client_secret" {
  type = string
  default = ""
  sensitive = true
  description = "Client Secret to use for this provider. (Optional)"
}

variable "client_secret_special" {
  type = bool
  default = true
  description = "Set to false to disable special characters in the client secret. (Optional)"
}

variable "access_token_validity" {
  type = string
  default = "minutes=10"
  description = "Access token validity period. (Optional)"
}

variable "client_type" {
  type = string
  default = "confidential"
  description = "Provider client type. Should be either \"confidential\" or \"public\". (Optional)"
}

variable "authorization_flow" {
  type = string
  default = "default-provider-authorization-implicit-consent"
  description = "Name of the authorization flow to use for the provider. (Optional)"
}

variable "invalidation_flow" {
  type = string
  default = "default-invalidation-flow"
  description = "Name of the invalidation flow to use for the provider. (Optional)"
}

variable "oauth_scopes" {
  type = list(string)
  default = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
  description = "Oauth scopes to assign to the provider. (Optional)"
}

variable "allowed_redirect_uris" {
  type = list(object({matching_mode = string, url = string}))
  default = [
    {
      matching_mode = "regex",
      url           = "https://.*.billv.ca/.*",
    }
  ]
  description = "Configuration for allowed application redirect URLs. (Optional)"
}

variable "app_group" {
  type = string
  default = "Home Services"
  description = "Group to assign the application to. {Optional}"
}
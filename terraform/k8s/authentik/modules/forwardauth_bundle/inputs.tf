variable "outpost_name" {
  type = string
  description = "Authentik outpost name to send forwardauth requests from Traefik to."
}

variable "app_name" {
  type = string
  description = "Human friendly application name."
}

variable "app_slug" {
  type = string
  description = "Machine friendly application name."
}

variable "app_external_host" {
  type = string
  description = "External URL for the application."
}
variable "app_namespace" {
  type = string
  description = "Namespace that the proxied application is running in. This is the namespace that the module will generate Traefik config in."
}

variable "app_group" {
  default = "Home Services"
  description = "Group to assign the application to. {Optional}"
}

variable "app_icon" {
  type = string
  default = ""
  description = "URL to an icon to assign to the application. (Optional)"
}

variable "additional_property_mapping_ids" {
  type = list(string)
  default = [ ]
  description = "List of additional property mapping IDs to assign to this provider. (Optional)"
}

variable "additional_auth_response_headers" {
  type = list(string)
  default = [ ]
  description = "List of additional headers to forward on to the application you're proxying to. (Optional)"
}

variable "refresh_token_validity" {
  type = string
  default = "hours=1"
  description = "How long tokens will be valid for. (Optional)"
}

variable "app_cookie_domain" {
  type = string
  default = "billv.ca"
  description = "Domain that cookies will be set for. (Optional)"
}

variable "app_mode" {
  type = string
  default = "forward_single"
  description = "Proxy mode. (Optional)"
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
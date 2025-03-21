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

variable "acs_url" {
  type = string
  description = "ACS Url for SSO"
}

variable "sp_binding" {
  type = string
  description = "Service provider binding"
  default = "post"
}

variable "audience" {
  type = string
  description = "Audience"
}

variable "certificate_name" {
  default = "authentik Self-signed Certificate"
  type = string
  description = "Name of certificate used to sign SAML requests."
}

variable "app_group_attributes" {
  type = string
  default = "{\"type\":\"app_user_group\"}"
  description = "Group attributes"
}

variable "app_icon" {
  type = string
  default = ""
  description = "URL to an icon to assign to the application. (Optional)"
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

variable "property_mappings" {
  type = list(string)
  default = [
  ]
  description = "SAML property mappings. (Optional)"
}

variable "app_group" {
  type = string
  default = "Home Services"
  description = "Group to assign the application to. {Optional}"
}
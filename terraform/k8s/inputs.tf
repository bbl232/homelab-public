variable "authentik_url" {
  type = map
}

variable "authentik_api_key" {
  type = map
  sensitive = true
}
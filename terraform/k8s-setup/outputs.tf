output "authentik_url" {
  value = "auth.billv.ca"
}

output "authentik_api_key" {
  value = module.authentik_system.authentik_api_key
  sensitive = true
}
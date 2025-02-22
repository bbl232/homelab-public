output "client_id" {
  value = random_password.client_id.result
  sensitive = false
  description = "Client ID configured for the provider."
}

output "client_secret" {
  sensitive = true
  value = authentik_provider_oauth2.app.client_secret
  description = "Client Secret configured for the provider."
}

output "admins_group_id" {
  value = authentik_group.app_admins.id
  description = "Authentik group that can be assigned to administrators of this application."
}

output "users_group_id" {
  value = authentik_group.app_users.id
  description = "Authentik group that can be assigned to users of this application."
}
output "client_id" {
  value = random_password.client_id.result
  sensitive = false
}

output "client_secret" {
  value = authentik_provider_oauth2.mealie.client_secret
}

output "admins_group_id" {
  value = authentik_group.mealie_admins.id
}

output "users_group_id" {
  value = authentik_group.mealie_users.id
}
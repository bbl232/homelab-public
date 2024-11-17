output "client_id" {
  value = random_password.client_id.result
  sensitive = false
}

output "admins_group_id" {
  value = authentik_group.ocis_admins.id
}

output "users_group_id" {
  value = authentik_group.ocis_users.id
}
output "client_secret" {
    sensitive = true
    value = authentik_provider_oauth2.proxmox.client_secret
}

output "users_group_id" {
    value = authentik_group.proxmox_users.id
}
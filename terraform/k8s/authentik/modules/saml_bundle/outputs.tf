output "users_group_id" {
    value = authentik_group.app_users.id
}

output "provider_id" {
    value = authentik_provider_saml.provider.id
}
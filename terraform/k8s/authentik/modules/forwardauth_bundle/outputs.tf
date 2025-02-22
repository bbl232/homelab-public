output "access_group_id" {
    value = authentik_group.app_access.id
    description = "Authentik group that can be assigned to grant users access to this application."
}

output "provider_id" {
    value = authentik_provider_proxy.app.id
    description = "Authentik provider ID that was created for this application. Must be added to an outpost for successful auth flow."
}
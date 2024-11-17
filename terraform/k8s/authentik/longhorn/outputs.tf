output "admins_group_id" {
    value = authentik_group.longhorn_admins.id
}

output "provider_id" {
    value = authentik_provider_proxy.longhorn.id
}
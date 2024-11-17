output "admins_group_id" {
    value = authentik_group.pihole_admins.id
}

output "provider_id" {
    value = authentik_provider_proxy.pihole.id
}
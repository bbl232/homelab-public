output "admins_group_id" {
    value = authentik_group.wireguard_admins.id
}

output "provider_id" {
    value = authentik_provider_proxy.wireguard.id
}
output "admins_group_id" {
    value = authentik_group.admins.id
}

output "provider_id" {
    value = authentik_provider_proxy.kube.id
}
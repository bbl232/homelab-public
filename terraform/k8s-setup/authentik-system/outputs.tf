output "authentik_api_key" {
    value = random_password.akadmin_api_key.result
    sensitive = true
}
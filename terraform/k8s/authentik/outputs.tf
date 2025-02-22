output "bill_pw" {
  value = random_password.bill_pw.result
  sensitive = true
}

output "trina_pw" {
  value = random_password.trina_pw.result
  sensitive = true
}

output "proxmox_client_secret" {
  value = module.proxmox.client_secret
  sensitive = true
}

output "mealie_client_id" {
  value = module.mealie.client_id
}

output "mealie_client_secret" {
  value = module.mealie.client_secret
  sensitive = true
}

output "ocis_client_id" {
  value = module.ocis.client_id
}
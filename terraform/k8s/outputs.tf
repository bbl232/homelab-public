output "pfsense_acme_access_key_id" {
  value = module.pfsense_route53_credentials.pfsense_acme_access_key_id
}

output "pfsense_acme_access_key_secret" {
  value = module.pfsense_route53_credentials.pfsense_acme_access_key_secret
  sensitive = true
}

output "bill_pw" {
  value = module.authentik.bill_pw
  sensitive = true
}

output "proxmox_client_secret" {
  value = module.authentik.proxmox_client_secret
  sensitive = true
}
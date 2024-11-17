output "pfsense_acme_access_key_id" {
  value = aws_iam_access_key.pfsense_acme.id
}

output "pfsense_acme_access_key_secret" {
  value = aws_iam_access_key.pfsense_acme.secret
  sensitive = true
}
terraform {
  required_providers {
    authentik = {
        source = "goauthentik/authentik"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  aws_saml_provider_name = "Authentik3s"
  aws_saml_role_name = "Authentik-SAML-Admin"
}

resource "authentik_group" "aws_admins" {
    name = "AWS Admins"
    attributes = "{\"aws_role\": \"${local.aws_saml_role_name}\"}"
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-invalidation-flow"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_saml" "aws" {
    acs_url = "https://signin.aws.amazon.com/saml"
    name = "AWS"
    authorization_flow = data.authentik_flow.default_authorization_flow.id
    invalidation_flow = data.authentik_flow.default_invalidation_flow.id
    sp_binding = "post"
    audience = "urn:amazon:webservices"
    property_mappings = [authentik_property_mapping_provider_saml.saml_aws_rolessessionname.id,authentik_property_mapping_provider_saml.saml_aws_role.id]
    signing_kp = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "AWS" {
    slug = "aws"
    protocol_provider = authentik_provider_saml.aws.id
    name = "AWS"
    group = "Cloud Services"
    meta_icon = "https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg"
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.AWS.uuid
  group  = authentik_group.aws_admins.id
  order  = 0
}

data "authentik_provider_saml_metadata" "aws" {
  depends_on = [ authentik_provider_saml.aws ]
  provider_id = authentik_provider_saml.aws.id
}

// Start AWS Resources
//
// Now we link AWS to the authentik provider we just set up

data "aws_caller_identity" "current" {}

resource "aws_iam_saml_provider" "authentik" {
  depends_on = [ authentik_provider_saml.aws ]
  name                   = local.aws_saml_provider_name
  saml_metadata_document = data.authentik_provider_saml_metadata.aws.metadata
}

resource "authentik_property_mapping_provider_saml" "saml_aws_rolessessionname" {
  name       = "SAML AWS RoleSessionName"
  saml_name  = "https://aws.amazon.com/SAML/Attributes/RoleSessionName"
  expression = "return user.username"
}

resource "authentik_property_mapping_provider_saml" "saml_aws_role" {
  name       = "SAML AWS Role"
  saml_name  = "https://aws.amazon.com/SAML/Attributes/Role"
  expression = <<EOF
role_name = user.group_attributes().get("aws_role", "")
return f"arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/{role_name},arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/${local.aws_saml_provider_name}"
EOF
}

data "aws_iam_policy" "administrator" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "billing" {
  name = "Billing"
}

resource "aws_iam_role" "saml_admin" {
  name = "Authentik-SAML-Admin"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": aws_iam_saml_provider.authentik.arn
            },
            "Action": "sts:AssumeRoleWithSAML",
            "Condition": {
                "StringEquals": {
                    "SAML:aud": "https://signin.aws.amazon.com/saml"
                }
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin-attach" {
  role       = aws_iam_role.saml_admin.name
  policy_arn = data.aws_iam_policy.administrator.arn
}

resource "aws_iam_role_policy_attachment" "billing-attach" {
  role       = aws_iam_role.saml_admin.name
  policy_arn = data.aws_iam_policy.billing.arn
}
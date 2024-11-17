terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    aws = {
        source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_user" "pfsense_acme" {
  name = "pfsense-acme"
  path = "/system/"
}

resource "aws_iam_user_policy" "pfsense_acme_dns" {
  name = "Route53ACME"
  user = aws_iam_user.pfsense_acme.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListTagsForResources",
                "route53:GetChange",
                "route53:ListTrafficPolicyInstancesByHostedZone",
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ListVPCAssociationAuthorizations",
                "route53:ListResourceRecordSets",
                "route53:GetHostedZoneLimit",
                "route53:GetDNSSEC",
                "route53:ListTagsForResource",
                "route53:ListQueryLoggingConfigs"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*",
                "arn:aws:route53:::change/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListReusableDelegationSets",
                "route53:ListTrafficPolicyInstances",
                "route53:GetTrafficPolicyInstanceCount",
                "route53:TestDNSAnswer",
                "route53:ListHostedZones",
                "route53:ListHostedZonesByName",
                "route53:GetAccountLimit",
                "route53:ListHostedZonesByVPC",
                "route53:GetCheckerIpRanges",
                "route53:ListHealthChecks",
                "route53:ListTrafficPolicies",
                "route53:GetGeoLocation",
                "route53:ListGeoLocations",
                "route53:ListCidrCollections",
                "route53:GetHostedZoneCount",
                "route53:GetHealthCheckCount"
            ],
            "Resource": "*"
        }
    ]
    })
}

resource "aws_iam_access_key" "pfsense_acme" {
    user = aws_iam_user.pfsense_acme.name
}
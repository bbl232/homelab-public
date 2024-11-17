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

data "aws_route53_zone" "billv_ca" {
  name         = "billv.ca."
}

resource "aws_iam_user" "cert_manager" {
  name = "k8s-cert-manager"
  path = "/system/"
}

resource "aws_iam_user_policy" "cert_manager_acme_dns" {
  name = "Route53ACME"
  user = aws_iam_user.cert_manager.name

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

resource "aws_iam_access_key" "cert_manager" {
    user = aws_iam_user.cert_manager.name
}

resource "kubernetes_secret_v1" "credentials" {
    metadata {
      name = "route53-credentials-secret"
      namespace = "cert-manager"
    }

    data = {
      access-key-id = resource.aws_iam_access_key.cert_manager.id
      secret-access-key = resource.aws_iam_access_key.cert_manager.secret
    }
}

resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt"
    }
    "spec" = {
      "acme" = {
        "email" = "bill@vandenberk.me"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-account-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "route53" = {
                "accessKeyIDSecretRef" = {
                  "key" = "access-key-id"
                  "name" = "route53-credentials-secret"
                }
                "region" = "us-east-1"
                "secretAccessKeySecretRef" = {
                  "key" = "secret-access-key"
                  "name" = "route53-credentials-secret"
                }
              }
            }
          },
        ]
      }
    }
  }
}

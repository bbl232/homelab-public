terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    helm = {
        source = "hashicorp/helm"
    }
    aws = {
        source = "hashicorp/aws"
    }
  }
}

resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "aws_s3_bucket" "longhorn_backups" {
  bucket = "longhorn-backups.billv.ca"
}

resource "aws_iam_user" "longhorn" {
  path = "/system/"
  name = "longhorn"
}

resource "aws_iam_user_policy" "s3" {
  name = "longhorn-s3"
  user = aws_iam_user.longhorn.name
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GrantLonghornBackupstoreAccess0",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.longhorn_backups.arn}",
        "${aws_s3_bucket.longhorn_backups.arn}/*"
      ]
    }
  ]})
}

resource "aws_iam_access_key" "longhorn" {
  user = aws_iam_user.longhorn.name
}

resource "kubernetes_secret_v1" "longhorn_backups_credentials" {
  metadata {
    name = "longhorn-backups-credentials"
    namespace = kubernetes_namespace.longhorn_system.metadata.0.name
  }
  data = {
    AWS_ACCESS_KEY_ID = aws_iam_access_key.longhorn.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.longhorn.secret
  }
}

resource "helm_release" "longhorn" {
  name = "longhorn"
  repository = "https://charts.longhorn.io"
  chart = "longhorn"
  version = "1.8.1"
  namespace = kubernetes_namespace.longhorn_system.metadata.0.name
  create_namespace = false

  set {
    name = "defaultSettings.backupTarget"
    value = "s3://${aws_s3_bucket.longhorn_backups.id}@${aws_s3_bucket.longhorn_backups.region}/"
  }
  set {
    name = "defaultSettings.backupTargetCredentialSecret"
    value = kubernetes_secret_v1.longhorn_backups_credentials.metadata.0.name
  }
  set {
    name = "defaultSettings.backupstorePollInterval"
    value = "0"
  }
}

resource "kubernetes_manifest" "certificate_authentik_star_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "longhorn-billv-ca"
      "namespace" = kubernetes_namespace.longhorn_system.metadata.0.name
    }
    "spec" = {
      "dnsNames" = [
        "longhorn.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "longhorn-billv-ca"
    }
  }
}


resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "longhorn"
      "namespace" = kubernetes_namespace.longhorn_system.metadata.0.name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`longhorn.billv.ca`)"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = kubernetes_namespace.longhorn_system.metadata.0.name
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "longhorn-frontend"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "longhorn-billv-ca"
      }
    }
  }
}

resource "kubernetes_manifest" "recurringjob_longhorn_system_daily_backup" {
  manifest = {
    "apiVersion" = "longhorn.io/v1beta1"
    "kind" = "RecurringJob"
    "metadata" = {
      "name" = "daily-backup"
      "namespace" = "longhorn-system"
    }
    "spec" = {
      "concurrency" = 1
      "cron" = "0 4 * * *"
      "groups" = [
        "default",
      ]
      "retain" = 1
      "task" = "backup-force-create"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "tfstate.billv.ca"
    key = "k8s/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  ignore_annotations = [
    "metallb\\.universe\\.tf\\/ip-allocated-from-pool",
    "kubectl\\.kubernetes\\.io\\/restartedAt"
  ]
}

provider "authentik" {
  //url = "https://${lookup(var.authentik_url, "value")}"
  url = "https://auth.billv.ca"
  token = lookup(var.authentik_api_key, "value")
  insecure = true
}

module "metallb" {
  source = "./metallb"
}

module "cert_manager" {
  source = "./cert-manager"
}

module "authentik" {
  source = "./authentik"
}

module "mealie-system" {
  source = "./mealie-system"
  OIDC_CLIENT_ID = module.authentik.mealie_client_id
  OIDC_CLIENT_SECRET = module.authentik.mealie_client_secret
}

module "pfsense_route53_credentials" {
  source = "./pfsense-route53-credentials"
}

module "dns" {
  source = "./dns"
}

module "wireguard" {
  source = "./wireguard"
}

module "ocis" {
  client_id = module.authentik.ocis_client_id
  source = "./ocis"
}

module "meshcentral" {
  source = "./meshcentral"
}
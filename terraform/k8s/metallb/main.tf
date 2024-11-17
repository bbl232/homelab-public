resource "kubernetes_manifest" "ipaddresspool_metallb_system_first_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind" = "IPAddressPool"
    "metadata" = {
      "name" = "first-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "addresses" = [
        "10.206.100.0-10.206.110.255",
      ]
    }
  }
}

resource "kubernetes_manifest" "l2advertisement_metallb_system_default" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind" = "L2Advertisement"
    "metadata" = {
      "name" = "default"
      "namespace" = "metallb-system"
    }
  }
}

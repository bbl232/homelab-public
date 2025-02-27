resource "kubernetes_manifest" "traefik_entrypoints" {
    manifest = {
        "apiVersion" = "helm.cattle.io/v1"
        "kind" = "HelmChartConfig"
        "metadata" = {
            "name" = "traefik"
            "namespace" = "kube-system"
         }
         "spec" = {
            "valuesContent" = <<-EOF
deployment:
    podAnnotations:
    prometheus.io/port: "8082"
    prometheus.io/scrape: "true"
providers:
    kubernetesIngress:
        publishedService:
            enabled: true
priorityClassName: "system-cluster-critical"
image:
    repository: "rancher/mirrored-library-traefik"
    tag: "2.11.10"
tolerations:
    - key: "CriticalAddonsOnly"
      operator: "Exists"
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule"
    - key: "node-role.kubernetes.io/master"
      operator: "Exists"
      effect: "NoSchedule"
service:
    ipFamilyPolicy: "PreferDualStack"
ports:
    websecure:
        forwardedHeaders:
            trustedIPs:
                - 10.0.0.0/8
logs:
    access:
        enabled: true
EOF
         }
    }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  depends_on = [
    null_resource.wait_for_eks,
    null_resource.wait_for_nodes
  ]

  values = [<<EOF
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
EOF
  ]

  timeout = 600
}

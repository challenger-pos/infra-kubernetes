resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [<<EOF
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
EOF
  ]

  timeout = 600
}

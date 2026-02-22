# Recursos Kubernetes com dependência do node group
# CONFIG_MAP permite acesso IAM automático + configuração explícita

resource "kubernetes_namespace" "datadog_agent" {
  metadata {
    name = "datadog-agent"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group
  ]
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true
  
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.node.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
    
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::422110551791:user/Thiago_Frederico"
        username = "Thiago_Frederico"
        groups   = ["system:masters"]
      },
      {
        userarn  = "arn:aws:iam::422110551791:user/Thiago_Tierre"
        username = "Thiago_Tierre"
        groups   = ["system:masters"]
      },
      {
        userarn  = "arn:aws:iam::422110551791:user/Luigi_Braghittoni"
        username = "Luigi_Braghittoni"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group
  ]
  
  lifecycle {
    replace_triggered_by = [
      aws_eks_cluster.cluster
    ]
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  depends_on = [
    aws_eks_node_group.node_group,
    kubernetes_config_map_v1_data.aws_auth
  ]

  values = [<<EOF
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
EOF
  ]

  timeout = 600
  
  lifecycle {
    replace_triggered_by = [
      aws_eks_cluster.cluster
    ]
  }
}

resource "helm_release" "datadog_agent" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = "datadog-agent"
  version    = "3.45.0"

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set {
    name  = "datadog.site"
    value = "us5.datadoghq.com"
  }

  set {
    name  = "logs.enabled"
    value = true
  }

  set {
    name  = "logs.containerCollectAll"
    value = true
  }

  set {
    name  = "apm.enabled"
    value = true
  }

  depends_on = [
    kubernetes_namespace.datadog_agent,
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group,
    kubernetes_config_map_v1_data.aws_auth,
    helm_release.lb_controller
  ]
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"

  depends_on = [
    aws_eks_node_group.node_group,
    kubernetes_config_map_v1_data.aws_auth,
    aws_iam_role.lb_controller,
    aws_iam_role_policy_attachment.lb_controller_attach,
  ]

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }
  
  set {
    name  = "region"
    value = var.region_default
  }
  
  set {
    name  = "vpcId"
    value = local.vpc_id
  }
  
  lifecycle {
    replace_triggered_by = [
      aws_eks_cluster.cluster
    ]
  }
}

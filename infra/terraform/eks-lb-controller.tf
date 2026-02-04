resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "lb_controller" {
  name = "${var.projectName}-eks-lb-controller-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.lb_controller.name
}

resource "aws_iam_role_policy_attachment" "lb_controller_ec2_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.lb_controller.name
}

resource "aws_iam_role_policy" "lb_controller_additional" {
  name = "${var.projectName}-lb-controller-additional-${var.environment}"
  role = aws_iam_role.lb_controller.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["iam:CreateServiceLinkedRole"]
      Resource = "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/*"
    }]
  })
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"  # Especifique a versão

  depends_on = [
    aws_eks_node_group.node_group,
    aws_iam_role.lb_controller,
    aws_iam_role_policy_attachment.lb_controller_attach,
    aws_eks_cluster.cluster
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
}
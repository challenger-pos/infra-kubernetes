data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.cluster.name
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "lb_controller" {
  name = "eks-lb-controller-role"

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
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
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
  name = "eks-lb-controller-additional"
  role = aws_iam_role.lb_controller.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["iam:CreateServiceLinkedRole"]
      Resource = "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/*"
    }]
  })
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  depends_on = [
    null_resource.wait_for_eks,
    null_resource.wait_for_nodes,
    aws_iam_role_policy_attachment.lb_controller_attach
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
    value = data.terraform_remote_state.rds.outputs.vpc_id
  }
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "Permissoes para o EKS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "elasticloadbalancing:*",
          "iam:CreateServiceLinkedRole",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_final_attach" {
  policy_arn = aws_iam_policy.lb_controller_policy.arn
  role       = aws_iam_role.lb_controller.name
}
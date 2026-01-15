resource "aws_eks_cluster" "cluster" {
  name     = "eks-${var.projectName}"
  version  = "1.34"
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids         = [
      aws_subnet.eks_public_1.id,
      aws_subnet.eks_public_2.id
    ]
    security_group_ids = [aws_security_group.challengeone_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode                 = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = concat(
      local.public_subnet_ids,
      local.private_app_subnet_ids
    )
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = merge(
    local.eks_tags,
    {
      Name = local.cluster_name
    }
  )
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "nodeg-${var.projectName}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [
    aws_subnet.eks_public_1.id,
    aws_subnet.eks_public_2.id
  ]
  disk_size = 50
  instance_types = [ "t3.micro" ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config { 
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]
}
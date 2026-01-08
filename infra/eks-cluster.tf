resource "aws_eks_cluster" "cluster" {
  name     = "eks-${var.projectName}"
  version  = "1.34"
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_public[0].id,
      aws_subnet.subnet_public[1].id,
      aws_subnet.subnet_public[2].id,
      aws_subnet.subnet_private[0].id,
      aws_subnet.subnet_private[1].id,   
      aws_subnet.subnet_private[2].id 
    ]
    # security_group_ids = [aws_security_group.challengeone_sg.id]
  }

  # depends_on = [
  #   aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  # ]
}

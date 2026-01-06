data "aws_iam_user" "princpal_user" {
  user_name = "challengeone-tf"
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "main" {
  name = data.aws_eks_cluster.cluster.name
}

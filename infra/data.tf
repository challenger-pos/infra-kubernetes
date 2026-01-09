data "aws_iam_user" "princpal_user" {
  user_name = "challengeone-tf"
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "main" {
  name = data.aws_eks_cluster.cluster.name
}

# data "aws_security_group" "eks_node_sg" {
#   id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
# }

# data "aws_eks_node_group" "node_group" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = aws_eks_node_group.node_group.node_group_name
# }
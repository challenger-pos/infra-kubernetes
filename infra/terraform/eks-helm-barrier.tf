resource "null_resource" "wait_for_eks" {
  depends_on = [
    aws_eks_cluster.cluster
  ]

  provisioner "local-exec" {
    command = "aws eks wait cluster-active --name ${aws_eks_cluster.cluster.name}"
  }
}

resource "null_resource" "wait_for_nodes" {
  depends_on = [
    aws_eks_node_group.node_group
  ]

  provisioner "local-exec" {
    command = "aws eks wait nodegroup-active --cluster-name ${aws_eks_cluster.cluster.name} --nodegroup-name ${aws_eks_node_group.node_group.node_group_name}"
  }
}

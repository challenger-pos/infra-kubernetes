# resource "kubernetes_namespace" "challengeone" {
#   depends_on = [ 
#     aws_eks_cluster.cluster,
#     aws_eks_node_group.node_group
#   ]
#   metadata {
#     name = "challengeone"
#   }
# }
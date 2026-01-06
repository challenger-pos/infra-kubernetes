resource "kubernetes_namespace" "challengeone" {
  depends_on = [ 
    aws_eks_cluster.cluster
  ]
  metadata {
    name = "challengeone"
  }
}
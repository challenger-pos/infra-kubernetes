output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "challengeone_sg_id" {
  description = "Security Group do EKS Cluster"
  value       = aws_security_group.challengeone_sg.id
}

output "eks_private_subnets" {
  description = "IDs das subnets privadas usadas pelo cluster para LoadBalancer interno"
  value       = [
    aws_subnet.eks_private_1.id,
    aws_subnet.eks_private_2.id
  ]
}
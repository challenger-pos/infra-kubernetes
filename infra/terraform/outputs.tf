output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security Group do EKS Cluster (managed)"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_custom_security_group_id" {
  description = "Security Group customizado do EKS Cluster"
  value       = aws_security_group.eks_cluster.id
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data for kubectl"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}
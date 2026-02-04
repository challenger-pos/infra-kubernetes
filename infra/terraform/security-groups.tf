# Security Group EKS Cluster

resource "aws_security_group" "eks_cluster" {
  name        = "${var.projectName}-eks-cluster-sg-${var.environment}"
  description = "Security group for EKS cluster"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow nodes to communicate with cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.projectName}-eks-cluster-sg-${var.environment}"
    Environment = var.environment
  }
}

# Security Group Rules - Managed Node Group

# Acesso na porta 8080 (aplicação)
resource "aws_security_group_rule" "cluster_ingress_8080" {
  description       = "Allow ingress on port 8080 from anywhere"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Considere restringir em produção
  security_group_id = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

# NodePort range para Services
resource "aws_security_group_rule" "cluster_ingress_nodeports" {
  description       = "Allow NodePort range"
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Considere restringir em produção
  security_group_id = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}
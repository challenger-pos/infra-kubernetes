# resource "aws_security_group" "challengeone_sg" {
#   name        = "${var.projectName}-sg"
#   description = "Enables access to the ChallengeOne application"
#   vpc_id      = aws_vpc.vpc_challengeone.id

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.vpc_challengeone.cidr_block]
#     security_groups = [aws_security_group.api_gateway_vpc_link.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }



# # EKS Node Security Group (modify existing or add rules)
# resource "aws_security_group_rule" "eks_nodes_from_alb" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_eks_node_group.main.remote_access[0].ec2_ssh_key # Your EKS node SG
#   source_security_group_id = aws_security_group.challengeone_alb.id
# }

# # ALB Security Group
# resource "aws_security_group" "challengeone_alb" {
#   name_prefix = "challengeone-alb-"
#   description = "Security group for ChallengeOne ALB"
#   vpc_id      = aws_vpc.vpc_challengeone.id

#   # Allow traffic from API Gateway VPC Link
#   ingress {
#     from_port                = 80
#     to_port                  = 80
#     protocol                 = "tcp"
#     source_security_group_id = aws_security_group.api_gateway_vpc_link.id
#   }

#   # Allow outbound to EKS nodes
#   egress {
#     from_port                = 8080
#     to_port                  = 8080
#     protocol                 = "tcp"
#     source_security_group_id = var.eks_node_security_group_id  # Reference to EKS node SG
#   }

#   tags = {
#     Name = "${var.projectName}-alb-sg"
#   }
# }

# # API Gateway VPC Link Security Group
# resource "aws_security_group" "api_gateway_vpc_link" {
#   name_prefix = "api-gateway-vpc-link-"
#   description = "Security group for API Gateway VPC Link"
#   vpc_id      = aws_vpc.vpc_challengeone.id

#   # Allow outbound to ALB
#   egress {
#     from_port                = 80
#     to_port                  = 80
#     protocol                 = "tcp"
#     source_security_group_id = aws_security_group.challengeone_alb.id
#   }

#   tags = {
#     Name = "${var.projectName}-api-gateway-vpc-link-sg"
#   }
# }

# # Output the security group IDs for other repositories
# output "alb_security_group_id" {
#   value = aws_security_group.challengeone_alb.id
# }

# output "api_gateway_vpc_link_security_group_id" {
#   value = aws_security_group.api_gateway_vpc_link.id
# }




# ALB Security Group (base)
resource "aws_security_group" "challengeone_alb" {
  name_prefix = "challengeone-alb"
  description = "Security group for ChallengeOne ALB"
  vpc_id      = aws_vpc.vpc_challengeone.id

  tags = {
    Name = "${var.projectName}-alb-sg"
  }
}

# API Gateway VPC Link Security Group (base)
resource "aws_security_group" "api_gateway_vpc_link" {
  name_prefix = "api-gateway-vpc-link-"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = aws_vpc.vpc_challengeone.id

  tags = {
    Name = "${var.projectName}-api-gateway-vpc-link-sg"
  }
}

# Rules for ALB Security Group
resource "aws_security_group_rule" "alb_ingress_from_api_gateway" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.challengeone_alb.id
  source_security_group_id = aws_security_group.api_gateway_vpc_link.id
}

resource "aws_security_group_rule" "alb_egress_to_eks_nodes" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.challengeone_alb.id
  source_security_group_id = data.aws_security_group.eks_node_sg.id # You'll need to get this from your EKS setup
}

# Rules for API Gateway VPC Link Security Group
resource "aws_security_group_rule" "api_gateway_egress_to_alb" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api_gateway_vpc_link.id
  source_security_group_id = aws_security_group.challengeone_alb.id
}

# Rule to allow ALB to reach EKS nodes
resource "aws_security_group_rule" "eks_nodes_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.challengeone_alb.id
}
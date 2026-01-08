output "vpc_cidr" {
  value = aws_vpc.vpc_challengeone.cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc_challengeone.id
}

output "subnet_cidr" {
  value = aws_subnet.subnet_public[*].cidr_block
}

output "subnet_id" {
  value = aws_subnet.subnet_public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.subnet_private[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.challengeone_alb.id
}

# output "vpc_link_sg_id" {
#   value = aws_security_group.challengeone_sg.id
# }

output "api_gateway_vpc_link_security_group_id" {
  value = aws_security_group.api_gateway_vpc_link.id
}

output "eks_node_security_group_id" {
  value = aws_eks_node_group.node_group.resources[0].remote_access_security_group_id
}
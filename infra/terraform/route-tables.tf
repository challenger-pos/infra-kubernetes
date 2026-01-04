resource "aws_route_table" "eks_public" {
  vpc_id = data.terraform_remote_state.rds.outputs.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}

resource "aws_route_table_association" "eks_public_1" {
  subnet_id      = aws_subnet.eks_public_1.id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table_association" "eks_public_2" {
  subnet_id      = aws_subnet.eks_public_2.id
  route_table_id = aws_route_table.eks_public.id
}

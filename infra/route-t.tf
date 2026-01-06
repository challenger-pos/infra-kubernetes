resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc_challengeone.id

  route {
    cidr_block = aws_vpc.vpc_challengeone.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association_0" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[0].id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_1" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[1].id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_2" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[2].id
  route_table_id = aws_route_table.route_table_public.id
}
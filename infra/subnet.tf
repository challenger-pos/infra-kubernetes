resource "aws_subnet" "subnet_public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc_challengeone.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_challengeone.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-2a", "us-east-2b", "us-east-2c"][count.index]

  tags = var.tags
}
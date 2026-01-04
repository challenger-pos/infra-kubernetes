resource "aws_subnet" "eks_public_1" {
  vpc_id                  = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-1"
  }
}

resource "aws_subnet" "eks_public_2" {
  vpc_id                  = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-2"
  }
}

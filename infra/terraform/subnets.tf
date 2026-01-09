resource "aws_subnet" "eks_public_1" {
  vpc_id                  = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-1"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/eks-challengeone-g19" = "shared"
  }
}

resource "aws_subnet" "eks_public_2" {
  vpc_id                  = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-1"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/eks-challengeone-g19" = "shared"
  }
}

resource "aws_subnet" "eks_private_1" {
  vpc_id            = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "eks-private-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks-challengeone-g19" = "shared"
  }
}

resource "aws_subnet" "eks_private_2" {
  vpc_id            = data.terraform_remote_state.rds.outputs.vpc_id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "eks-private-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks-challengeone-g19" = "shared"
  }
}

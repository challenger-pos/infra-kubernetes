resource "aws_internet_gateway" "eks" {
  vpc_id = data.terraform_remote_state.rds.outputs.vpc_id

  tags = {
    Name = "eks-igw"
  }
}

locals {
  vpc_id                = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.networking.outputs.public_subnet_ids
  private_app_subnet_ids = data.terraform_remote_state.networking.outputs.private_app_subnet_ids
  
  cluster_name = "eks-${var.projectName}"
  
  eks_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}
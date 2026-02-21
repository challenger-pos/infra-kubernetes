terraform {
  backend "s3" {
    bucket  = "tf-state-challenge-bucket"
    region  = "us-east-2"
  }
}

# IMPORTANTE: Para trocar de ambiente, reconfigure o backend:
# terraform init -reconfigure -backend-config="key=v4/kubernetes/dev/terraform.tfstate"
# terraform init -reconfigure -backend-config="key=v4/kubernetes/homologation/terraform.tfstate"
# terraform init -reconfigure -backend-config="key=v4/kubernetes/production/terraform.tfstate"
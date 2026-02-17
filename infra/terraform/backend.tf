terraform {
  backend "s3" {
    bucket  = "tf-state-challenge-bucket"
    key     = "v4/kubernetes/dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
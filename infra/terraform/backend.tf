terraform {
  backend "s3" {
    bucket = "tf-state-challenge-bucket"
    key    = "kubernetes/terraform.tfstate"
    region = "us-east-2"
  }
}
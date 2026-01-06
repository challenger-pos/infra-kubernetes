terraform {
  backend "s3" {
    bucket = "tf-state-challenge-bucket"
    key    = "challengeOne/terraform.tfstate"
    region = "us-east-2"
  }
}
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/networking/${var.environment}/terraform.tfstate"
    region = "us-east-2"
  }
}
data "terraform_remote_state" "rds" {
  backend = "s3"

  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "rds/terraform.tfstate"
    region = "us-east-2"
  }
}
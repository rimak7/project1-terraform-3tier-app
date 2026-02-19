terraform {
  backend "s3" {
    bucket = "my-project1-terraform-p1"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"

  }
}
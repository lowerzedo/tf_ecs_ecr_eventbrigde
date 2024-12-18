terraform {
  backend "s3" {
    region = "ap-southeast-1"
    bucket = "terraform-state-123169"
    key    = "terraform.tfstate"
  }
}

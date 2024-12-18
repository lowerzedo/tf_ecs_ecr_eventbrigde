terraform {
  backend "s3" {
    region = "ap-southeast-1"
    bucket = "moodle-odl-terraform-state"
    key    = "terraform.tfstate"
  }
}

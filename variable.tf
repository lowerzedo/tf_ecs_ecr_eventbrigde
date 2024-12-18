variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "sync-odl-script"
}

variable "region" {
  description = "The region the environment is going to be installed into"
  type        = string
  default     = "ap-southeast-1"
}

# VPC variables
variable "vpc_id" {
  description = "ID of the VPC"
  default     = "vpc-0ebda1e2cd671a2ed"
}

variable "vpc_cidr" {
  description = "CIDR range of VPC"
  type        = string
  default     = "172.31.0.0/16"
}


# Project specific variables
variable "secret_name" {
  description = "Value of the secret name"
  type        = string
}



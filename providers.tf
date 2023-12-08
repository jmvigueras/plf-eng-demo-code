#--------------------------------------------------------------------------
# Terraform providers
#--------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region["id"]
  assume_role {
    role_arn     = var.aws_role_arn
    session_name = "ContainerIac"
    external_id  = var.aws_role_ext_id
  }
}
##############################################################################################################
# Github provider
##############################################################################################################
provider "github" {
  token = var.github_token
}
// GitHub Token variable
variable "github_token" {}

##############################################################################################################
# Providers variables
############################################################################################################### 
// AWS configuration
variable "access_key" {}
variable "secret_key" {}
variable "aws_role_ext_id" {}
variable "aws_role_arn" {}
variable "region" {
  default = {
    id  = "eu-west-1" // Ireland
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
}

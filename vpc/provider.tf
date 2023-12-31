## Declare the Terraform configuration block and Provider
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.31.0"
    }
  }
}

## Configure the AWS provider with desired region and credentials 
provider "aws" {
  region = "us-east-1"
  profile = "default"
  shared_credentials_files = [ "~/.aws/credentials" ]
}
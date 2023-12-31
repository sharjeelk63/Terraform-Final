# Declare the Terraform configuration block and specify required providers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

# Configure the AWS provider with the desired region and credentials file.
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Define an AWS EC2 instance resource named "demo-instance".
resource "aws_instance" "demo-instance" {
  ami           = "ami-0c7217cdde317cfec"  # Specify the Amazon Machine Image (AMI) for the instance.
  instance_type = "t2.micro"                # Specify the instance type.

  # Define tags for the instance.
  tags = {
    name = "demo"   # Tag indicating the name of the instance.
    env  = "dev"    # Tag indicating the environment (development) of the instance.
  }
}



provider "aws" {
  region  = "us-west-1"
  profile = ""
}

provider "aws" {
  region  = "us-east-1"
  alias = "us-east-1"
  profile = ""
}
terraform {
  required_version = ">= 1.7.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "s3resizer/terraform.tfstate"
    region = "us-east-1"
  }
}
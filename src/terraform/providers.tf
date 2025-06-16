terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket = "epicreads-terraform-statefile"
    key    = "dev/terraform-epicreads"
    region = "eu-north-1"
  }
}
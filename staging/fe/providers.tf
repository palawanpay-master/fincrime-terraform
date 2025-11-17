locals {
  common = {
    project_name = "fincrime-fe"
    environment  = "uat"
    region       = "ap-southeast-1"
  }
}

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = local.common.region

  default_tags {
    tags = {
      Environment      = local.common.environment
      Project          = local.common.project_name
      TerraformManaged = true
    }
  }
}
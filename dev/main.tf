terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Note variables cannot be used here, as an alternative we hard code the values
    # Initially we deploy backend-s3 first, then deploy an environment we just need
    # To keep in mind of the following:
    # - bucket and dynamodb_table prefix = the name of the project
    # - region = region of the s3 and dynamodb
    # - key = prefix of the environment e.g. (sandbox, dev, staging, uat, beta, prod)
    bucket = "ppay-fincrime-dev-terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
    # Uncomment this if you are running this locally
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "ppay-fincrime-dev"
  }
}

locals {
  common = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.region
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  # Uncomment this if you are running this locally
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
}

# Shared Parameters




# Github Runner
# module "ec2-github-runner" {
#   source = "../modules/ec2-github-runner"
#   common = local.common
#   github_runner_config = {
#     ami           = "ami-0cf70e1d861e1dfb8"
#     instance_type = "t2.medium"
#     vpc_id        = module.vpc.vpc_id
#     subnet_id     = module.vpc.private_subnet_ids[0]
#     user_data     = <<-EOF
#                         #!/bin/bash
#                         sudo yum install -y perl-Digest-SHA
#                         sudo yum install -y libicu
#                       EOF
#   }
# }

# We primarily deploy lambda resources via Serverless Framework
# Additional configurations from lambda that is out-of-scope of Serverless Framework
# Should be provisioned here
module "lambda-config" {
  source = "../modules/lambda-config"
  common = local.common
  lambda_config = {
    vpc_id = var.vpc_id
  }
}

# Centralized bucket for storing all necesarry objects
module "s3-private-storage" {
  source               = "../modules/s3-private-storage"
  create_ssm_parameter = true
  bucket_name          = "storage2"
  common               = local.common
}

module "s3-serverless-artifacts" {
  source               = "../modules/s3-private-storage"
  create_ssm_parameter = false
  bucket_name          = "serverless-artifacts2"
  common               = local.common
}

module "external-ssm-paramters" {
  source = "../modules/external-ssm-parameters"
  common = local.common
  params = {
    redshift_hostName = var.redshift_hostName
    redshift_database = var.redshift_database
    redshift_secrets  = var.redshift_secrets
    mongodb_secrets   = var.mongodb_secrets
  }
}

# Cognito for authentication
module "cognito-user-pool" {
  source = "../modules/cognito-admin"
  common = local.common
}


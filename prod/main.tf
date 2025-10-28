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
    bucket         = "oneinfinite-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    dynamodb_table = "oneinfinite-terraform-state-lock-table"
    region         = "ap-southeast-1"
    # Uncomment this if you are running this locally
    # shared_credentials_files = ["~/.aws/credentials"]
    # profile                  = ""
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
  # shared_credentials_files = ["~/.aws/credentials"]
  # profile                  = var.aws_profile
}

# Application Network
module "vpc" {
  source = "../modules/vpc"
  common = local.common
  vpc_config = {
    vpc_cidr                       = "10.51.0.0/16"
    public_subnet_cidrs            = ["10.51.0.0/20", "10.51.16.0/20"]
    private_subnet_cidrs           = ["10.51.128.0/20", "10.51.144.0/20"]
    availability_zones             = ["${var.region}a", "${var.region}b"]
    nat_gateway_availability_zones = "single"
  }
}

module "ec2-bastion-host" {
  source = "../modules/ec2-bastion-host"
  common = local.common
  bastion_config = {
    ami           = "ami-04b6019d38ea93034"
    instance_type = "t2.medium"
    vpc_id        = module.vpc.vpc_id
    subnet_id     = module.vpc.private_subnet_ids[0]
    user_data     = <<-EOF
                      #!/bin/bash
                      echo "Starting user_data script" >> /tmp/user_data.log
                      sudo yum update -y >> /tmp/user_data.log 2>&1
                      sudo amazon-linux-extras enable postgresql15 >> /tmp/user_data.log 2>&1
                      sudo yum install -y postgresql15 >> /tmp/user_data.log 2>&1
                    EOF
  }
}

# Strapi Fargate 
module "ecs-fargate-strapi" {
  source = "../modules/ecs-fargate-strapi"
  common = local.common
  strapi_config = {
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.public_subnet_ids
    private_subnets     = module.vpc.private_subnet_ids
    acm_certificate_arn = var.strapi_app_acm_certificate_arn
  }
}

# We primarily deploy lambda resources via Serverless Framework
# Additional configurations from lambda that is out-of-scope of Serverless Framework
# Should be provisioned here
module "lambda-config" {
  source = "../modules/lambda-config"
  common = local.common
  lambda_config = {
    vpc_id = module.vpc.vpc_id
  }
}

# Bus for event driven executions
module "event-bridge" {
  source = "../modules/event-bridge"
  common = local.common
}

# Centralized bucket for storing all necesarry objects
module "s3-private-storage" {
  source = "../modules/s3-private-storage"
  common = local.common
}

module "s3-public-storage" {
  source = "../modules/s3-public-storage"
  common = local.common
}

# Primary RDS
module "rds" {
  source = "../modules/rds"
  common = local.common
  db_config = {
    database_name               = "${var.project_name}"
    username                    = "postgres"
    manage_master_user_password = true
    engine                      = "postgres"
    engine_version              = "16.8"
    instance_class              = "db.t4g.medium"
    port                        = 5432
    storage_type                = "gp2"
    allocated_storage           = 20
    max_allocated_storage       = 50
    iops                        = null
    publicly_accessible         = false
    multi_az                    = false
    vpc_id                      = module.vpc.vpc_id
    vpc_subnet_ids              = module.vpc.private_subnet_ids
    additional_ingress_security_groups = [
      module.ec2-bastion-host.security_group_id,
      module.ecs-fargate-strapi.security_group_id
    ]
    additional_ingress_cidr_blocks        = []
    availability_zone                     = "${var.region}a"
    ca_cert_identifier                    = "rds-ca-rsa2048-g1"
    performance_insights_enabled          = false
    performance_insights_retention_period = 0
    backup_retention_period               = 7
    backup_window                         = "00:00-03:00" # Treat this is as UTC
    maintenance_window                    = "Sat:03:15-Sat:04:15"
    copy_tags_to_snapshot                 = true
    monitoring_interval                   = 0
    deletion_protection                   = false
    skip_final_snapshot                   = true
  }
  db_proxy_config = {
    engine_family             = "POSTGRESQL"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "DISABLED"
    debug_logging             = false
    idle_client_timeout       = 1800
    connection_borrow_timeout = 120
    max_connections_percent   = 90
    additional_ingress_security_groups = [
      # module.lambda-config.security_group_id,
      module.ec2-bastion-host.security_group_id,
      module.ecs-fargate-strapi.security_group_id
    ]
  }
}

module "external-ssm-paramters" {
  source = "../modules/external-ssm-parameters"
  common = local.common
  params = {
    shopify_admin_access_token      = var.shopify_admin_access_token
    shopify_storefront_access_token = var.shopify_storefront_access_token
    shopify_base_url                = var.shopify_base_url
    octopus_api_username            = var.octopus_api_username
    octopus_api_password            = var.octopus_api_password
    octopus_api_auth                = var.octopus_api_auth
    octopus_base_url                = var.octopus_base_url
    octopus_custom_rules_action     = var.octopus_custom_rules_action
    octopus_custom_rules_crm_id     = var.octopus_custom_rules_crm_id
    jwt_secret                      = var.jwt_secret
    jwt_refresh_expiry_day          = var.jwt_refresh_expiry_day
    jwt_algo                        = var.jwt_algo
    rsa_private_base_64             = var.rsa_private_base_64
    strapi_api_auth                 = var.strapi_api_auth
    strapi_cms_base_url             = var.strapi_cms_base_url
    pinpoint_project_id             = var.pinpoint_project_id
    s3_public_upload_base_url       = var.s3_public_upload_base_url
  }
}

module "ddb-models" {
  source = "../modules/ddb-models"
  common = local.common
}

module "sqs" {
  source = "../modules/sqs"
  common = local.common
}

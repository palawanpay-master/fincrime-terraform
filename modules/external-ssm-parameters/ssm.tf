# SSM Parameters
# Defined project configurations

resource "aws_ssm_parameter" "mongodb_secrets" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/mongodb/secrets"
  description = "MongoDB Secrets"
  type        = "SecureString"
  value       = jsonencode(var.params.mongodb_secrets)
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
resource "aws_ssm_parameter" "redshift_hostName" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/redshift/hostName"
  description = "Redshift Host Name"
  type        = "String"
  value       = var.params.redshift_hostName
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
resource "aws_ssm_parameter" "redshift_database" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/redshift/database"
  description = "Redshift Database Name"
  type        = "String"
  value       = var.params.redshift_database
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
resource "aws_ssm_parameter" "redshift_secrets" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/redshift/secrets"
  description = "Redshift Secrets"
  type        = "SecureString"
  value       = jsonencode(var.params.redshift_secrets)
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

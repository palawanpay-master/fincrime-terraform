# SSM Parameters
# Defined project configurations

resource "aws_ssm_parameter" "mongodb_uri" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/mongodb/uri"
  description = "MongoDB URI"
  type        = "SecureString"
  value       = var.params.mongodb_uri
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "mongodb_uri_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/mongodb/uri/arn"
  description = "MongoDB URI ARN"
  type        = "String"
  value       = aws_ssm_parameter.mongodb_uri.arn
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

resource "aws_ssm_parameter" "redshift_tableName" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/redshift/tableName"
  description = "Redshift Table Name"
  type        = "String"
  value       = var.params.redshift_tableName
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

resource "aws_ssm_parameter" "redshift_secrets_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/redshift/secrets/arn"
  description = "Redshift Secrets ARN"
  type        = "String"
  value       = aws_ssm_parameter.redshift_secrets.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}


resource "aws_ssm_parameter" "security_group_ids" {
  for_each = {
    for index, sg_id in var.params.security_group_ids : index => sg_id
  }

  name        = "/${var.common.project_name}/${var.common.environment}/external/security-groups/${each.key}"
  description = "Security Group ID ${each.key}"
  type        = "String"
  value       = each.value

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "subnet_ids" {
  for_each = {
    for index, subnet_id in var.params.subnet_ids : index => subnet_id
  }

  name        = "/${var.common.project_name}/${var.common.environment}/external/subnets/${each.key}"
  description = "Subnet ID ${each.key}"
  type        = "String"
  value       = each.value

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "cedarpy_layer_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/layers/cedarpy-python311/arn"
  description = "ARN of the cedarpy Lambda Layer (Python 3.11)"
  type        = "String"
  value       = aws_lambda_layer_version.cedarpy.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}




locals {
  # make the file path absolute, relative to THIS module folder
  cedarpy_layer_source_abs = "${path.module}/${var.cedarpy_layer_source}"
}

# 1) Upload ZIP to S3
resource "aws_s3_object" "cedarpy_layer_zip" {
  bucket = var.artifacts_bucket
  key    = var.cedarpy_layer_key
  source = local.cedarpy_layer_source_abs
  etag   = filemd5(local.cedarpy_layer_source_abs)
}

# 2) Create Lambda Layer from S3 object
resource "aws_lambda_layer_version" "cedarpy" {
  layer_name          = "cedarpy-python311"
  s3_bucket           = aws_s3_object.cedarpy_layer_zip.bucket
  s3_key              = aws_s3_object.cedarpy_layer_zip.key
  compatible_runtimes = ["python3.11"]
  description         = "CedarPy built on Amazon Linux for Lambda"
}


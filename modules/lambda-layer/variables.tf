variable "common" {
  type = object({
    project_name = string
    environment  = string
    region       = string
  })
}

variable "artifacts_bucket" {
  description = "S3 bucket to upload Lambda layers/artifacts"
  type        = string
}

variable "cedarpy_layer_key" {
  description = "S3 key/path for the cedarpy layer zip"
  type        = string
  default     = "layers/cedarpy-layer.zip"
}

variable "cedarpy_layer_source" {
  description = "Local path to the cedarpy layer zip (built from Docker)"
  type        = string
}

variable "project_name" {
  type = string
}
variable "state_lock_region" {
  type = string
}
variable "web_app_acm_certificate_arn" {
  type = string
}
variable "strapi_app_acm_certificate_arn" {
  type = string
}
variable "cloudfront_acm_certificate_arn" {
  type = string
}
variable "shopify_admin_access_token" {
  type = string
}
variable "shopify_storefront_access_token" {
  type = string
}
variable "shopify_base_url" {
  type = string
}
variable "octopus_api_username" {
  type = string
}
variable "octopus_api_password" {
  type = string
}
variable "octopus_api_auth" {
  type = string
}
variable "octopus_base_url" {
  type = string
}
variable "octopus_custom_rules_action" {
  type = string
}
variable "octopus_custom_rules_crm_id" {
  type = string
}
variable "jwt_secret" {
  type = string
}
variable "jwt_refresh_expiry_day" {
  type = string
}
variable "jwt_algo" {
  type = string
}
variable "rsa_private_base_64" {
  type = string
}
variable "strapi_api_auth" {
  type = string
}
variable "strapi_cms_base_url" {
  type = string
}
variable "pinpoint_project_id" {
  type = string
}
variable "s3_public_upload_base_url" {
  type = string
}

# Optional Resources
# The following values here should be defined on the start of the project,
# But can also be substituted via the tfvars file.
variable "environment" {
  type    = string
  default = "prod"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}

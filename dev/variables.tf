variable "project_name" {
  type = string
}
variable "state_lock_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "mongodb_secrets" {
  description = "MongoDB Secrets"
  type = object({
    username = string
    password = string
  })
}

variable "redshift_hostName" {
  type = string
}

variable "redshift_database" {
  type = string
}

variable "redshift_secrets" {
  type = object({
    username = string
    password = string
  })
}


# Optional Resources
# The following values here should be defined on the start of the project,
# But can also be substituted via the tfvars file.
variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}

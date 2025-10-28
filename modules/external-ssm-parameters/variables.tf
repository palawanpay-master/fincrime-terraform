# [MANDATORY] 
#  - Define common for consuming shared parameters
#  - Omit any parameters that are not needed
variable "common" {
  type = object({
    project_name = string
    environment  = string
    region       = string
  })

}

variable "params" {
  type = object({
    mongodb_secrets = object(
      {
        username = string
        password = string
      }
    )
    redshift_hostName = string
    redshift_database = string
    redshift_secrets = object(
      {
        username = string
        password = string
      }
    )
  })
}

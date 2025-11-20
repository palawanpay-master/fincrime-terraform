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
    mongodb_uri             = string
    redshift_hostName       = string
    redshift_cust_tableName = string
    redshift_merc_tableName = string
    redshift_database       = string
    redshift_secrets = object(
      {
        username = string
        password = string
      }
    )
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

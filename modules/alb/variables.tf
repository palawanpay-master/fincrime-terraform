variable "common" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "http_redirect" {
  type    = bool
  default = false
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}


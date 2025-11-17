terraform {
  backend "s3" {
    bucket = "palawanpay-fincrime-fe-uat-tf-state"
    key    = "tfstate"
    region = "ap-southeast-1"
  }
}
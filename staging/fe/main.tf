module "internal_nlb_ecs" {
  source = "git::ssh://git@${var.SSH_KEY}/palawanpay/IaCTerraformForInfra.git//modules/internal_nlb_ecs"
  common = local.common
  target_group = {
    port     = 3000 
    protocol = "TCP"
    health_check = {
      path                = "/"
      protocol            = "TCP"
      matcher             = "200-302"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 3
      unhealthy_threshold = 3
    }
  }

  vpc = {
    vpc_id = "vpc-0895ffb8f088c03ab" # got from vpc provisioned by LZA
    app_subnet_ids = {               # got from subnets provisioned by LZA
      "app-subnet-a" : "subnet-0a499f830920aab30",
      "app-subnet-b" : "subnet-014e07d5add6d9f81",
      "app-subnet-c" : "subnet-0ba52b0944885455e",
    }
  }

  ecs = {
    service_capacity_provider = "FARGATE"
    task_cpu                  = "2048"
    task_memory               = "4096"
  }

  secret_arn = "arn:aws:secretsmanager:ap-southeast-1:663958379235:secret:fincrime-fe-uat-secret-jsXrb0"
}
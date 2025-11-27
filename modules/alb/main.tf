# --- ALB ---
resource "aws_lb" "alb" {
  name               = "${var.common.project_name}-${var.common.environment}-${var.alb_name}"
  load_balancer_type = "application"
  subnets            = var.internal ? var.private_subnets : var.public_subnets
  internal           = var.internal
  enable_http2       = true

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# --- Target Group ---
resource "aws_lb_target_group" "frontend" {
  name     = "${var.common.project_name}-${var.common.environment}-${var.alb_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/auth/login"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# --- HTTP listener (redirect to HTTPS) ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# --- HTTPS listener ---
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# --- Optional path-based listener rule ---
resource "aws_lb_listener_rule" "auth_path" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/auth/*"]
    }
  }
}

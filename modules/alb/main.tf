resource "aws_lb" "main" {
  name               = "${var.alb_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.subnets
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  access_logs {
    bucket  = var.alb_access_log_bucket
    prefix  = var.pitstop_name
    enabled = true
  }
  tags = {
    Name          = "${var.alb_name}-alb"
    Environment   = var.environment
    Participant    = var.Participant
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.alb_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name          = "${var.alb_name}-alb-tg"
    Environment   = var.environment
    Participant    = var.Participant
  }
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect traffic to target group
resource "aws_alb_listener" "https" {
    load_balancer_arn = aws_lb.main.id
    port              = 443
    protocol          = "HTTPS"

    ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    certificate_arn   = var.alb_tls_cert_arn

    default_action {
        type = "fixed-response"
        fixed_response {
          content_type = "text/plain"
         message_body = "Welcome to CDI Platform"
         status_code  = "200"
    }
    }
}
resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_alb_listener.https.arn
  #priority     = var.lb_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    host_header {
      values = ["${var.pitstop_name}.pitstop.sgtradex.io"]
    }
  }
}
resource "aws_route53_record" "pitstop_dns_record" {
  name    = "${lower(var.pitstop_name)}"
  type    = "A"
  zone_id = var.route53_hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
  }
}
resource "aws_wafv2_web_acl_association" "web_acl_association_acl" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.waf_arn
}

output "aws_alb_listner_arn" {
  value = aws_alb_listener.https.arn
}
output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}
output "aws_lb_main_dns_name" {
  value = aws_lb.main.dns_name
}
output "aws_lb_main_zone_id" {
  value = aws_lb.main.zone_id
}

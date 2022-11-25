
resource "aws_alb_target_group" "sandbox_main" {
  #name        = "sandbox-${var.alb_name}-tg"
  name        = var.pitstop_name == "exxonmobil-chemicals" ?  "sb-${var.alb_name}-tg" : "sandbox-${var.alb_name}-tg"
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
    Name          = "sandbox-${var.alb_name}-alb-tg"
    Environment   = var.environment
    Participant    = var.Participant
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.aws_alb_listener_https_arn
  #priority     = var.lb_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.sandbox_main.arn
  }

  condition {
    host_header {
      values = ["sandbox-${var.pitstop_name}.pitstop.sgtradex.io"]
    }
  }
}
resource "aws_route53_record" "pitstop_dns_record" {
  name    = "sandbox-${lower(var.pitstop_name)}"
  type    = "A"
  zone_id = var.route53_hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = var.aws_lb_main_dns_name
    zone_id                = var.aws_lb_main_zone_id
  }
}

output "sandbox_aws_alb_target_group_arn" {
  value = aws_alb_target_group.sandbox_main.arn
}


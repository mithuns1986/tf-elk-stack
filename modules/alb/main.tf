resource "aws_lb" "main" {
  name                       = "${var.alb_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.subnets
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  tags = {
    Name        = "${var.alb_name}-alb"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "es" {
  name        = "${var.alb_name}-es-tg"
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
    path                = "/_cat/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.alb_name}-es-tg"
    Environment = var.environment
  }
}

## Logstash Target Group

resource "aws_alb_target_group" "logstash" {
  name        = "${var.alb_name}-logstash-tg"
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
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.alb_name}-logstash-tg"
    Environment = var.environment
  }
}

## Kibana Target group
resource "aws_alb_target_group" "kibana" {
  name        = "${var.alb_name}-kibana-tg"
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
    path                = "/app/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.alb_name}-kibana-tg"
    Environment = var.environment
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

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Welcome to ELK"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_alb_listener.https.arn
  #priority     = var.lb_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.es.arn
  }

  condition {
    host_header {
      values = ["es.${var.doamin_name}"]
    }
  }
}
output "aws_alb_listner_arn" {
  value = aws_alb_listener.https.arn
}
output "es_aws_alb_target_group_arn" {
  value = aws_alb_target_group.es.arn
}

output "logstash_aws_alb_target_group_arn" {
  value = aws_alb_target_group.logstash.arn
}

output "kibana_aws_alb_target_group_arn" {
  value = aws_alb_target_group.kibana.arn
}

output "aws_lb_main_dns_name" {
  value = aws_lb.main.dns_name
}
output "aws_lb_main_zone_id" {
  value = aws_lb.main.zone_id
}

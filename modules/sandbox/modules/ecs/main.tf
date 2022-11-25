
resource "aws_ecs_task_definition" "sandbox_main" {
  family                   = "sandbox-${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  container_definitions = jsonencode([{
    name        = "pitstop"
    image       = "${var.container_image}:latest"
    essential   = true
    environment = var.container_environment
    portMappings = var.sandbox_container_port_mappings
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])

  tags = {
    Name        = "sandbox-${var.name}-task"
    Environment = var.environment
    Participant = var.Participant
  }
}

resource "aws_ecs_service" "sandbox_main" {
  name                               = "sandbox-${var.name}-service"
  cluster                            = var.aws_ecs_cluster_main_id
  task_definition                    = aws_ecs_task_definition.sandbox_main.arn
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = var.ecs_service_security_groups
    subnets          = var.subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = "pitstop"
    container_port   = var.sandbox_container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "sandbox_ecs_target" {
  max_capacity       = 2
  min_capacity       = 2
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.sandbox_main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.name}memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sandbox_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.sandbox_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sandbox_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "sandbox_ecs_policy_cpu" {
  name               = "${var.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sandbox_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.sandbox_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sandbox_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
output "service_name" {
  value = "${aws_ecs_service.sandbox_main.name}"
}




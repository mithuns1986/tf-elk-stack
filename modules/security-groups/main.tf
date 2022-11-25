resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-sg-alb"
    Environment = var.environment
    Participant    = var.Participant
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.name}-sg-task"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    security_groups      = ["${aws_security_group.alb.id}"]
  }
  ingress {
    protocol         = "tcp"
    from_port        = var.sandbox_container_port
    to_port          = var.sandbox_container_port
    security_groups      = ["${aws_security_group.alb.id}"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-sg-task"
    Environment = var.environment
    Participant    = var.Participant
  }
}
resource "aws_security_group" "rds_sg" {
  name = "${var.name}-rds-sg"
  vpc_id = "${var.vpc_id}"
  tags = {
    Name        = "${var.name}-rds-sg"
    Environment = var.environment
    Participant    = var.Participant
  }

  //allow traffic for TCP 5432
  ingress {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      security_groups = ["${aws_security_group.ecs_tasks.id}"]
  }
  ingress {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      cidr_blocks = ["10.99.0.0/22"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb" {
  value = aws_security_group.alb.id
}

output "ecs_tasks" {
  value = aws_security_group.ecs_tasks.id
}
output "rds_sg" {
  value = aws_security_group.rds_sg.id
}

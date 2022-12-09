resource "aws_security_group" "alb" {
  name   = "ELK-sg-alb"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ELK-sg-alb"
    Environment = var.environment
  }
}

resource "aws_security_group" "logstash" {
  name   = "logstash-sg-task"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = "5010"
    to_port         = "5010"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  ingress {
    protocol        = "tcp"
    from_port       = "8080"
    to_port         = "8080"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "logstah-sg-task"
    Environment = var.environment
  }
}

resource "aws_security_group" "es" {
  name   = "es-sg-task"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = "9200"
    to_port         = "9200"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  ingress {
    protocol        = "tcp"
    from_port       = "9300"
    to_port         = "9300"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "es-sg-task"
    Environment = var.environment
  }
}

resource "aws_security_group" "kibana" {
  name   = "kibana-sg-task"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = "5601"
    to_port         = "5601"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "kibana-sg-task"
    Environment = var.environment
  }
}

output "alb" {
  value = aws_security_group.alb.id
}

output "logstash" {
  value = aws_security_group.logstash.id
}

output "es" {
  value = aws_security_group.es.id
}
output "kibana" {
  value = aws_security_group.kibana.id
}

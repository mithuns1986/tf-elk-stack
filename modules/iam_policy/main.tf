data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${lower(var.environment)}-${var.pitstop_name}-bucket/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "arn:aws:logs:ap-southeast-1:${var.aws_account}:log-group:${var.log_group}/*",
      "arn:aws:logs:ap-southeast-1:${var.aws_account}:log-group:${var.log_group}:log-stream:*",
      "arn:aws:logs:ap-southeast-1:${var.aws_account}:log-group:${var.sandbox_log_group}/*",
      "arn:aws:logs:ap-southeast-1:${var.aws_account}:log-group:${var.sandbox_log_group}:log-stream:*"
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]

    resources = [
      "*"
    ]
    effect = "Allow" 
  }
  statement {
    actions = [
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]
    effect = "Allow" 
  }
}
resource "aws_iam_policy" "example" {
  name   = "${var.environment}-${var.pitstop_name}-ecsTaskPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
#.......
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.pitstop_name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-${var.pitstop_name}-ecsTaskRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.example.arn
}
output "task_execution_role_arn" {
value = aws_iam_role.ecs_task_execution_role.arn
}
output "ecs_task_role_arn" {
value = aws_iam_role.ecs_task_role.arn
}
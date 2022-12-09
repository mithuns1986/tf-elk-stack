resource "aws_iam_policy" "example" {
  name   = "${var.environment}-elk-ecsTaskPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
#.......
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-elk-ecsTaskExecutionRole"

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
  name               = "${var.environment}-elk-ecsTaskRole"
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

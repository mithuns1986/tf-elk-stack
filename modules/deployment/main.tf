resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  name     = "${var.name}-ecr-image-push"
  role_arn = aws_iam_role.event_rule.arn

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]

    detail = {
      repository-name = ["${var.ecr_repo_name}"]
      image-tag       = [var.image_tag]
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
    }
  })
}
resource "aws_iam_role" "event_rule" {
  name = "${var.name}-cloudwatch-event-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_cloudwatch_event_target" "ecr_image_push" {
  rule      = aws_cloudwatch_event_rule.ecr_image_push.name
  target_id = var.codepipeline_name
  arn       = var.codepipeline_arn
  role_arn  = aws_iam_role.event_rule.arn
}

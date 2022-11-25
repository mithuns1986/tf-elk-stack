resource "aws_secretsmanager_secret" "sandbox_pitstop_secretes" {
  name                    = "sandbox-${var.environment}-${var.name}-sg-secretsManager"

  tags = {
       Environment = var.environment
       name        = "sandbox-${var.environment}-${var.name}-sg-secretsManager"
  }
}

resource "aws_secretsmanager_secret_version" "sandbox_pitstop_secrets_version" {
  secret_id     = aws_secretsmanager_secret.sandbox_pitstop_secretes.id
  secret_string = jsonencode({
    TYPEORM_PASSWORD  =  var.sandbox_typeorm_password
    PITSTOP_LICENSE_KEY = var.sandbox_pitstop_license_key
  })
}

resource "aws_iam_policy" "sandbox_policy_secretsmanager" {
  name = "sandbox-${var.environment}-${var.name}-sg-secretsmanagerPolicy"
  path = "/"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_secretsmanager_secret.sandbox_pitstop_secretes.arn}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "user-managed-policy-attachment" {
  role = "${var.environment}-${var.name}-ecsTaskExecutionRole"
  policy_arn = "${aws_iam_policy.sandbox_policy_secretsmanager.arn}"
}
resource "aws_iam_role_policy_attachment" "user-managed-policy-ecsTaskRole" {
  role = "${var.environment}-${var.name}-ecsTaskRole"
  policy_arn = "${aws_iam_policy.sandbox_policy_secretsmanager.arn}"
}
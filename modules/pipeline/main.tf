resource "aws_codepipeline" "codepipeline" {
  name     = "${var.environment}-${var.name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    #location = aws_s3_bucket.codepipeline_bucket.bucket
    location = "prod-pitstop-codepipeline-bucket"
    type     = "S3"

   # encryption_key {
   #   id   = data.aws_kms_alias.s3kmskey.arn
   #   type = "KMS"
   # }
  }

  stage {
    name = "Source"

    action {
      run_order        = 1
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["pitstop-image"]

      configuration = {
        RepositoryName = "${var.ecr_name}"
        ImageTag       = "latest"
      }
    }
    action {
      run_order        = 2
      name             = "Sourcebitbucket"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        BranchName           = "master"
        #ConnectionArn        = "${aws_codestarconnections_connection.example.arn}"
        ConnectionArn        = "${var.bitbucket_connection_arn}"
        FullRepositoryId     = "futurL33t/pitstop-ecs-deploy"
 
      }
    }
  }
  stage {
    name = "Deploy"

   action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.service_name}"
        FileName    = "${lower(var.environment)}-imageDefinitions.json"
      }
    }
  }
}

#resource "aws_codestarconnections_connection" "example" {
#  name          = "bitbucket-connection"
#  provider_type = "Bitbucket"
#}

#resource "aws_s3_bucket" "codepipeline_bucket" {
#  bucket = "test-bucket-codepipelinetest"
#  acl    = "private"
#}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.environment}-${var.name}-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.environment}-${var.name}-codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },

        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticloadbalancing:*",
                "cloudwatch:*",
                "s3:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },


        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

#data "aws_kms_alias" "s3kmskey" {
#  name = "alias/myKmsKey"
#}
output "codepipeline_role_arn" {
  value = "${aws_iam_role.codepipeline_role.arn}"
}
output "codepipeline_arn" {
  value = "${aws_codepipeline.codepipeline.arn}"
}
output "codepipeline_name" {
  value = "${aws_codepipeline.codepipeline.name}"
}
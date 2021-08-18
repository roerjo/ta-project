resource "aws_codebuild_project" "build" {
  name         = "${var.app_name}-build"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type     = "S3"
    location = "${aws_s3_bucket.pipeline_bucket.bucket}/source.zip"
    buildspec = file("buildspec/buildspec.yml")
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.app_name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "codebuild_logging_policy" {
  name = "codebuild-logging-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logging_policy.arn
}

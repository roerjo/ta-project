resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.app_name}-codepipeline"
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "s3"
    effect = "Allow"
    principals {
      identifiers = [
        aws_iam_role.codebuild_role.arn,
        aws_iam_role.codepipeline_role.arn,
      ]
      type = "AWS"
    }
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.pipeline_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.pipeline_bucket.bucket}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "pipeline_bucket" {
  bucket = aws_s3_bucket.pipeline_bucket.id
  policy = data.aws_iam_policy_document.s3.json
}

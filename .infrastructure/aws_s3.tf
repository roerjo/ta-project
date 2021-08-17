resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.app_name}-codepipeline"
  acl    = "private"
}

resource "aws_ecr_repository" "ecr" {
  name = var.app_name
  image_tag_mutability = "IMMUTABLE"
}

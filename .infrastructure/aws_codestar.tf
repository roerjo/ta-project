resource "aws_codestarconnections_connection" "codestar_github" {
  name          = "${var.app_name}-codestar-github"
  provider_type = "GitHub"
}

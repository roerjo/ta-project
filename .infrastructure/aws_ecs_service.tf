resource "aws_ecs_service" "service" {
  name                               = var.app_name
  cluster                            = "ta-cluster"
  task_definition                    = "${aws_ecs_task_definition.nginx_site.family}:${aws_ecs_task_definition.nginx_site.revision}"
  desired_count                      = 1
  platform_version                   = "1.4.0"
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent         = "200"

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    subnets = [
      "subnet-070d0e9676b2f4948", // us-east-1a
    ]

    assign_public_ip = true
  }
}

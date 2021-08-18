resource "aws_ecs_task_definition" "nginx_site" {
    family = "nginx-site"
    network_mode = "awsvpc"
    execution_role_arn = aws_iam_role.task_role.arn
    requires_compatibilities = ["FARGATE"]
    cpu = "256"
    memory = "512"

    container_definitions = jsonencode([
        {
            "name": "nginx",
            "image": "${aws_ecr_repository.ecr.repository_url}:feature-latest",
            "essential": true
        }
    ])
}

resource "aws_iam_role" "task_role" {
  name = "task-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "nginx_site" {
  family                   = "nginx-site"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      "name" : "nginx",
      "image" : "${aws_ecr_repository.ecr.repository_url}:feature-latest",
      "essential" : true,
      "portMappings" : [
        {
          "hostPort" : 80,
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.nginx_log.name,
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
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

resource "aws_iam_policy" "task_role_policy" {
  name = "default-task-role-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "ecr:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
          "servicediscovery:DeregisterInstance",
          "servicediscovery:UpdateInstanceCustomHealthStatus",
          "servicediscovery:RegisterInstance",
          "route53:CreateHealthCheck"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_cw_logs_policy_attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_group" "nginx_log" {
  name              = "/ecs/${var.app_name}/app"
  retention_in_days = 1
}

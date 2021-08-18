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
      ]
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

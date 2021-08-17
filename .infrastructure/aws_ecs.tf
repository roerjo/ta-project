resource "aws_ecs_cluster" "ta-cluster" {
    name = "ta-cluster"

    capacity_providers = [
        "FARGATE_SPOT"
    ]
}

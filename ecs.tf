# Create ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-cluster"
}

# Create Spot Fargate Config | Select either FARGATE or EC2
resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs.name
  capacity_providers = [
    "FARGATE"
  ]
}

# Build ECS Image
resource "null_resource" "build" {
  depends_on = [
    aws_ecr_repository.ecr
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    interpreter = [
      "/bin/sh",
      "-c"
    ]

    command = <<-EOF
        # Login to ECR (AWS STS AssumeRole)
        aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com

        # Build Docker Image
        docker build -t ${aws_ecr_repository.ecr.repository_url}:latest . --platform linux/x86_64
        
        # Push Docker Image to ECR
        docker push ${aws_ecr_repository.ecr.repository_url}:latest
    EOF
  }
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  depends_on = [
    aws_iam_role.ecs_execution_role,
    aws_iam_role.ecs_task_role
  ]

  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # 2 vCPU
  memory                   = 512 # 4 GB
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      environment = [
        {
          name  = "STAGE"
          value = "prod"
        }
      ]
    }
  ])
}

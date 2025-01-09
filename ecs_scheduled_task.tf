resource "aws_ecs_task_definition" "scheduled_task" {
  family                   = "${var.project_name}-scheduled-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
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
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        {
          name  = "STAGE"
          value = "prod"
        },
        {
          name  = "SECRET_NAME"
          value = var.secret_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${var.project_name}-logs"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = "${var.project_name}-schedule"
  description         = "Schedule for running ECS Task"
  schedule_expression = "cron(0/5 * * * ? *)" # Every 5 minutes
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${var.project_name}-target"
  rule      = aws_cloudwatch_event_rule.ecs_scheduled_task.name
  arn       = aws_ecs_cluster.ecs.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.scheduled_task.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets          = data.aws_subnets.public.ids
      security_groups  = [aws_security_group.ecs_task_sg.id]
      assign_public_ip = true
    }
  }
}

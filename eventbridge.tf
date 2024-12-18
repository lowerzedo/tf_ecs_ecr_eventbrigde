# Create Cron job to trigger ECS Task
resource "aws_scheduler_schedule" "schedule" {
  depends_on = [
    aws_iam_role.scheduler,
    aws_ecs_cluster.ecs,
    aws_ecs_task_definition.ecs_task,
    data.aws_subnets.private,
    aws_security_group.ecs_task_sg
  ]

  name                         = "${var.project_name}-schedule"
  description                  = "Schedule to trigger ECS Task"
  schedule_expression          = "cron(0/5 * * * ? *)" #for debugging scheduled every five minute | old cron(35 9 * * ? *)
  schedule_expression_timezone = "Asia/Kuala_Lumpur"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.ecs.arn
    role_arn = aws_iam_role.scheduler.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.ecs_task.arn
      launch_type         = "FARGATE"

      task_count = 1

      network_configuration {
        assign_public_ip = false
        subnets          = data.aws_subnets.private.ids
        security_groups  = [aws_security_group.ecs_task_sg.id]
      }

      capacity_provider_strategy {
        capacity_provider = "FARGATE"
        weight            = 1
      }
    }

    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts       = 10
    }
  }

  # Replace ECS Task when new task definition is available
  lifecycle {
    replace_triggered_by = [aws_ecs_task_definition.ecs_task.arn]
  }
}

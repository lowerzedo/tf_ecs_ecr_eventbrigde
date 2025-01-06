# Create Cron job to trigger ECS Task
resource "aws_scheduler_schedule" "schedule" {
  name                = "${var.project_name}-schedule"
  group_name          = "default"
  schedule_expression = "cron(0/5 * * * ? *)"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.ecs.arn
    role_arn = aws_iam_role.scheduler.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.ecs_task.arn
      launch_type         = "FARGATE"

      network_configuration {
        subnets          = data.aws_subnets.private.ids
        security_groups  = [aws_security_group.ecs_task_sg.id]
        assign_public_ip = false
      }
    }
  }
}

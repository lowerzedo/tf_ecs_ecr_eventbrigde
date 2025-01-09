output "cloudwatch_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.ecs_scheduled_task.arn
}

output "scheduled_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.scheduled_task.arn
}

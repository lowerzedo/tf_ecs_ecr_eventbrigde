# IAM role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com",
                    "logs.amazonaws.com"
                ]
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    POLICY
}


# Attach ECR Policy to ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach CW Logs Policy to ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_cloudwatch_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}



# Create IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com",
                    "s3.amazonaws.com"
                ]
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    POLICY
}


# Attach CW Logs to ECS Task role
resource "aws_iam_role_policy_attachment" "ecs_task_role_cloudwatch_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


# Create Scheduler IAM Role
resource "aws_iam_role" "scheduler" {
  name = "${var.project_name}-scheduler-role"

  assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "scheduler.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    POLICY
}


# Create Policy for Scheduler Role
resource "aws_iam_policy" "scheduler_policy" {
  depends_on = [
    aws_ecs_task_definition.ecs_task,
    aws_iam_role.scheduler
  ]

  name = "${var.project_name}-scheduler-policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ecs:*",
            "iam:PassRole",
            "logs:*",
            "ec2:*",
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ecs:*",
            "ec2:*",
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:PassRole"
          ],
          "Resource" : [
            "${aws_iam_role.ecs_task_role.arn}",
            "${aws_iam_role.ecs_execution_role.arn}"
          ]
        }
      ]
    }
  )
}

# Attach Policy to Scheduler Role
resource "aws_iam_role_policy_attachment" "scheduler_policy" {
  depends_on = [
    aws_iam_policy.scheduler_policy
  ]

  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

# IAM policy to allow access to specific secrets in Secrets Manager
resource "aws_iam_policy" "secrets_manager_access_policy" {
  name = "${var.project_name}-secrets-manager-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*"
      }
    ]
  })
}

# Attach Secrets Manager access policy to ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_role_secrets_manager_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Add CloudWatch permissions to execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_cloudwatch" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "scheduler_policy" {
  name = "${var.project_name}-scheduler-inline-policy"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ]
        Resource = aws_ecs_task_definition.ecs_task.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters"
        ]
        Resource = aws_ecs_cluster.ecs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_role.arn,
          aws_iam_role.ecs_execution_role.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

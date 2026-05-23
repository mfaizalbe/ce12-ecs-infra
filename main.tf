resource "aws_ecr_repository" "s3_repo" {
  name = "s3-service"
}

resource "aws_ecr_repository" "sqs_repo" {
  name = "sqs-service"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "faizal-coaching-18-s3-bucket"
}

resource "aws_sqs_queue" "queue" {
  name = "app-queue"
}

resource "aws_ecs_cluster" "cluster" {
  name = "demo-cluster"
}

# create ECS IAM role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleMini"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# attach ECS policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# add S3 + SQS permission
resource "aws_iam_role_policy" "custom_policy" {
  name = "ecs-custom-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = "*"
      }
    ]
  })
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# IAM Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "example_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Policy básica para logs da Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}


# Lambda Function
resource "aws_lambda_function" "example_lambda" {
  filename         =  "${path.root}/../app/dist/lambda_function.zip"
  function_name    = "example_lambda"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"

  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }
}

# IAM Role para Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "example_step_functions_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# Policy para Step Functions invocar Lambda
resource "aws_iam_role_policy" "step_functions_policy" {
  name = "example_step_functions_policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.example_lambda.arn
        ]
      }
    ]
  })
}

# Step Function Definition
resource "aws_sfn_state_machine" "example_sfn" {
  name     = "example_state_machine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    StartAt = "ProcessData"
    States = {
      ProcessData = {
        Type = "Task"
        Resource = aws_lambda_function.example_lambda.arn
        End = true
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"]
            IntervalSeconds = 3
            MaxAttempts = 2
            BackoffRate = 1.5
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "FailState"
          }
        ]
      }
      FailState = {
        Type = "Fail"
        Cause = "Lambda function failed to process data"
      }
    }
  })
}

# Outputs
output "lambda_function_arn" {
  value = aws_lambda_function.example_lambda.arn
}

output "step_function_arn" {
  value = aws_sfn_state_machine.example_sfn.arn
}
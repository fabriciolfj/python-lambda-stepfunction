# IAM Role para a Lambda de trigger
resource "aws_iam_role" "trigger_lambda_role" {
  name = "step_function_trigger_role"

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

# Política para permitir que a Lambda inicie a Step Function
resource "aws_iam_role_policy" "trigger_lambda_policy" {
  name = "step_function_trigger_policy"
  role = aws_iam_role.trigger_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution",
          "states:DescribeStateMachine",
          "states:ListStateMachines"
        ]
        Resource = [data.aws_sfn_state_machine.existing_step_function.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Policy básica para logs da Lambda
resource "aws_iam_role_policy_attachment" "trigger_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.trigger_lambda_role.name
}

# Lambda Function de trigger
resource "aws_lambda_function" "trigger_lambda" {
  filename         = "./dist/trigger_lambda2.zip"
  function_name    = "step_function_trigger"
  role            = aws_iam_role.trigger_lambda_role.arn
  handler         = "trigger_lambda.lambda_handler"
  runtime         = "python3.9"

  environment {
    variables = {
      STEP_FUNCTION_ARN = data.aws_sfn_state_machine.existing_step_function.arn
    }
  }
}

# Opcional: API Gateway para invocar a Lambda via HTTP
resource "aws_apigatewayv2_api" "trigger_api" {
  name          = "step-function-trigger-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "trigger_api" {
  api_id = aws_apigatewayv2_api.trigger_api.id
  name   = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "trigger_lambda" {
  api_id           = aws_apigatewayv2_api.trigger_api.id
  integration_type = "AWS_PROXY"

  integration_uri    = aws_lambda_function.trigger_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "trigger_lambda" {
  api_id = aws_apigatewayv2_api.trigger_api.id
  route_key = "POST /trigger"
  target    = "integrations/${aws_apigatewayv2_integration.trigger_lambda.id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.trigger_api.execution_arn}/*/*"
}

# Output para a URL do API Gateway
output "api_gateway_url" {
  value = "${aws_apigatewayv2_api.trigger_api.api_endpoint}/prod/trigger"
  description = "URL do endpoint para triggerar a Step Function"
}

data "aws_sfn_state_machine" "existing_step_function" {
  name = "example_state_machine"  # Use o nome exato da sua Step Function
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_funtion_dir
  output_path = "${path.module}/${var.environment}_lambda_function.zip"
}

resource "aws_lambda_function" "health_check" {
  function_name    = "${var.environment}-serverless-health-check-api"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      ENVIRONMENT         = var.environment
    }
  }

  tags = var.common_tags

  depends_on = [data.archive_file.lambda_zip]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

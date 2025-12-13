output "api_endpoint" {
  description = "HTTP API endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "lambda_name" {
  value = aws_lambda_function.health_check.function_name
}

output "dynamodb_table" {
  value = aws_dynamodb_table.requests.name
}

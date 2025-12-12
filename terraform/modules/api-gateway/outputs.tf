output "api_endpoint" {
  description = "The endpoint URL of the API Gateway"
  value       = "${aws_apigatewayv2_api.health_api.api_endpoint}/"
}

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.health_api.id
}

output "execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.health_api.execution_arn
}

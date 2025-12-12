output "table_name" {
  description = "Name of the DynamoDB"
  value       = aws_dynamodb_table.requests.name
}

output "table_arn" {
  description = "ARN of the DynamoDB"
  value       = aws_dynamodb_table.requests.arn
}
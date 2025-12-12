variable "environment" {
  description = "Environment name"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

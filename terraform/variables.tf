variable "env" {
  description = "Environment name (staging or prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Lambda settings
variable "lambda_handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.9"
}

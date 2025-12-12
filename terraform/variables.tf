variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region"
  type        = string
}

variable "terraform_backend_bucket" {
  default     = "serverlesshealthcheckapi"
  description = "AWS S3 Bucket for Terraform backend"
  type        = string
}

variable "environment" {
  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "Environment must be either staging or prod"
  }
  description = "Deployment environment name (staging or prod)"
  type        = string
}

variable "lambda_funtion_dir" {
  default     = "../lambda"
  description = "Directory containing Lambda function source code"
  type        = string
}
variable "project_name" {
  default     = "serverless-health-check-api"
  description = "Project name for tagging and resource naming"
  type        = string
}
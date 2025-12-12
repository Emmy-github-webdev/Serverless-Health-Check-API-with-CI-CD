terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# DynamoDB Module
module "dynamodb" {
  source = "./modules/dynamodb"
  environment  = var.environment
  common_tags  = local.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn
  common_tags        = local.common_tags
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"
  environment       = var.environment
  lambda_invoke_arn = module.lambda.function_invoke_arn
  common_tags       = local.common_tags
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"
  environment                = var.environment
  lambda_role_arn            = module.iam.lambda_role_arn
  dynamodb_table_name        = module.dynamodb.table_name
  api_gateway_execution_arn  = module.api_gateway.execution_arn
  lambda_funtion_dir          = var.lambda_funtion_dir
  common_tags                = local.common_tags
  # depends_on = [module.api_gateway]
}


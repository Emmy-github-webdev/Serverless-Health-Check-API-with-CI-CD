data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_package/${var.env}-lambda.zip"

  source {
    content  = file("${path.module}/../lambda/lambda_function.py")
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "health_check" {
  function_name    = "${var.env}-health-check-function"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      REQUESTS_TABLE = aws_dynamodb_table.requests.name
    }
  }

  tags = {
    Environment = var.env
  }
}

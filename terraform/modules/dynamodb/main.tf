resource "aws_dynamodb_table" "requests" {
  name           = "${var.environment}-requests-db"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "request_id"

  attribute {
    name = "request_id"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = var.common_tags
}

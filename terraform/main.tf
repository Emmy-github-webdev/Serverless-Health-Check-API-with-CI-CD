resource "aws_dynamodb_table" "requests" {
  name         = "${var.env}-requests-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.env
    Name        = "${var.env}-requests-db"
  }
}

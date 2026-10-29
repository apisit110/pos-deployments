locals {
  tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
  }
}

# IAM role for Lambda execution (ใช้ร่วมกันทุก Lambda)
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

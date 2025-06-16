data "aws_iam_policy_document" "contact_lambda_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "contact_lambda_role" {
  name               = "contact_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.contact_lambda_policy.json
}

resource "aws_iam_role_policy" "contact_lambda_policy" {
  name = "contact_lambda_policy"
  role = aws_iam_role.contact_lambda_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ses:SendEmail"
      Resource = ["*"]
    }]
  })
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "contact_lambda"
  description   = "Lambda function for sending contact-us emails"
  handler       = "exports.handler"
  runtime       = "nodejs22.x"
  role_name     = aws_iam_role.contact_lambda_role.name

  source_path = "${path.module}/contact_lambda.js"

  tags = {
    Name = "my-lambda1"
  }
}
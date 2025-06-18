resource "aws_dynamodb_table" "contact_us_table" {
    name = "Contact_us_table"
    read_capacity = 5
    write_capacity = 5
    hash_key = "Customer_id"

    attribute {
        name = "Customer_id"
        type = "S"
    }

    attribute {
        name = "Name"
        type = "S"
    }

    attribute {
        name = "Email-Id"
        type = "S"
    }

    global_secondary_index {
        name               = "NameIndex"
        hash_key           = "Name"
        projection_type    = "ALL"
        read_capacity      = 5
        write_capacity     = 5
    }

    global_secondary_index {
        name               = "EmailIndex"
        hash_key           = "Email-Id"
        projection_type    = "ALL"
        read_capacity      = 5
        write_capacity     = 5
    }
}

resource "aws_iam_role" "data_management_lambda_role" {
    name = "data_management_lambda_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = ["lambda.amazonaws.com"]
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "data_management_lambda_policy" {
    role = aws_iam_role.data_management_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

module "data_management_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_management_lambda"
  description   = "Lambda function for managing contact-us data"
  handler       = "data_lambda.handler"
  runtime       = "python3.9"
  timeout       = "60"
  create_role   = false
  lambda_role   = aws_iam_role.data_management_lambda_role.arn

  source_path = "${path.module}/data_lambda_code"

  tags = {
    Environment = "Dev"
    managed_by  = "OPAKI"
  }
}

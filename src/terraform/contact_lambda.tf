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
  handler       = "contact_lambda.handler"
  runtime       = "nodejs22.x"
  timeout       = "60"
  create_role   = false
  lambda_role   = aws_iam_role.contact_lambda_role.arn

  source_path = "${path.module}/contact_lambda.js"

  tags = {
    Environment = "Dev"
    managed_by  = "OPAKI"
  }
}

resource "aws_api_gateway_rest_api" "contact_api_gateway" {
  name = "contact_api_gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  description = "Api Gateway for Lambda contact-us"
}

resource "aws_api_gateway_resource" "contact_api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.contact_api_gateway.root_resource_id
  path_part   = "epicreads_resource"
}

resource "aws_api_gateway_method" "contact_api_gateway_method" {
  http_method   = "POST"
  authorization = "NONE"
  resource_id   = aws_api_gateway_resource.contact_api_gateway_resource.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api_gateway.id
}

resource "aws_api_gateway_method" "contact_api_gateway_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api_gateway.id
  resource_id   = aws_api_gateway_resource.contact_api_gateway_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "contact_api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.contact_api_gateway.id
  resource_id             = aws_api_gateway_resource.contact_api_gateway_resource.id
  http_method             = aws_api_gateway_method.contact_api_gateway_method.http_method
  integration_http_method = "POST"
  uri                     = module.lambda_function.lambda_function_invoke_arn
  type                    = "AWS_PROXY"
}

resource "aws_api_gateway_integration" "contact_api_gateway_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_api_gateway.id
  resource_id = aws_api_gateway_resource.contact_api_gateway_resource.id
  http_method = aws_api_gateway_method.contact_api_gateway_options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "contact_api_gateway_options_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api_gateway.id
  resource_id = aws_api_gateway_resource.contact_api_gateway_resource.id
  http_method = aws_api_gateway_method.contact_api_gateway_options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "contact_api_gateway_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api_gateway.id
  resource_id = aws_api_gateway_resource.contact_api_gateway_resource.id
  http_method = aws_api_gateway_method.contact_api_gateway_options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api_gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [
    aws_api_gateway_integration.contact_api_gateway_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.contact_api_gateway.id
}

resource "aws_api_gateway_stage" "api_deploy_stage" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.contact_api_gateway.id
}

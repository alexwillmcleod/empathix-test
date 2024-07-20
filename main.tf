provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_api_gateway_rest_api" "coffee-order-api-gateway" {
  name        = "CoffeeOrderAPIGateway"
  description = "API Gateway for Serverless Coffee Ordering Application"
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.coffee-order-api-gateway.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_resource" "order" {
  rest_api_id = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  parent_id   = aws_api_gateway_resource.orders.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_order" {
  rest_api_id   = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_order" {
  rest_api_id   = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_order" {
  rest_api_id   = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "patch_order" {
  rest_api_id   = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "PATCH"
  authorization = "NONE"
}

resource "aws_lambda_function" "function" {
  filename         = "${path.module}/lambda/function.zip"
  function_name    = "serverless_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")
  timeout = 300
  memory_size = 1024
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.coffee_orders.name
    }
  }
}

resource "aws_dynamodb_table" "coffee_orders" {
  name         = "CoffeeOrders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }


}

data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.coffee-order-api-gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "get_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.get_order.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_api_gateway_integration" "post_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id             = aws_api_gateway_resource.orders.id
  http_method             = aws_api_gateway_method.post_order.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_api_gateway_integration" "delete_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.delete_order.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_api_gateway_integration" "patch_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.coffee-order-api-gateway.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.patch_order.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.function.invoke_arn
}

output "api_endpoint" {
  value = "${aws_api_gateway_rest_api.coffee-order-api-gateway.execution_arn}/orders"
}

provider "aws" {
  profile = "default"
  region = "${var.aws_region}"
}

# Lambda

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  function_name = "episodic_lambda"
  runtime = "go1.x"
  handler = "lambda"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/lambda.zip"
  source_code_hash = "${base64sha256(file("../bin/lambda.zip"))}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
    }
  }
}

# API Gateway

resource "aws_api_gateway_rest_api" "EpisodicAPI" {
  name        = "EpisodicAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_deployment" "EpisodicAPITest" {
  depends_on = ["aws_api_gateway_integration.lambda"]
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  stage_name = "test"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.EpisodicAPI.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.lambda.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_deployment.EpisodicAPITest.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id   = "${aws_api_gateway_rest_api.EpisodicAPI.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"
}

# CloudWatch

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_logging_role" {
  name = "lamba_logging_role"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_role.arn}"
}

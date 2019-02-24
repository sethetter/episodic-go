provider "aws" {
  profile = "default"
  region = "us-east-1"
}

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

resource "aws_lambda_function" "main" {
  function_name = "episodic_main"
  runtime = "go1.x"
  handler = "main"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/main.zip"
  source_code_hash = "${base64sha256(file("../bin/main.zip"))}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.main.function_name}"
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

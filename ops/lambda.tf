# Common Lambda Resources
# ----------------------------------------

# TODO: Abstract lambda stuff into a module

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

resource "aws_iam_policy" "lambda_logging_policy" {
  name = "lamdba_logging_policy"
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

# Lambda: twilio
# ----------------------------------------

resource "aws_lambda_function" "twilio" {
  function_name = "episodic_twilio"
  runtime = "go1.x"
  handler = "twilio"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/twilio.zip"
  source_code_hash = "${filebase64sha256("../bin/twilio.zip")}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
      DATA_BUCKET = "${aws_s3_bucket.data.bucket}"
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_twilio" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.twilio.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.prod.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "twilio_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.twilio.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "twilio_lambda_logs_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_policy.arn}"
}

# Lambda: loadeps
# ----------------------------------------

resource "aws_lambda_function" "loadeps" {
  function_name = "episodic_loadeps"
  runtime = "go1.x"
  handler = "loadeps"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/loadeps.zip"
  source_code_hash = "${filebase64sha256("../bin/loadeps.zip")}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
      DATA_BUCKET = "${aws_s3_bucket.data.bucket}"
    }
  }
}

resource "aws_cloudwatch_log_group" "loadeps_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.loadeps.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "loadeps_lambda_logs_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_policy.arn}"
}

resource "aws_cloudwatch_event_rule" "daily" {
  name = "daily"
  # Runs at 10 AM UTC every day
  schedule_expression = "cron(0 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "loadeps_daily" {
  rule = "${aws_cloudwatch_event_rule.daily.name}"
  target_id = "${aws_lambda_function.loadeps.function_name}"
  arn = "${aws_lambda_function.loadeps.arn}"
}

resource "aws_lambda_permission" "loadeps_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.loadeps.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.daily.arn}"
}

# Lambda: watchlist
# ----------------------------------------

resource "aws_lambda_function" "watchlist" {
  function_name = "episodic_watchlist"
  runtime = "go1.x"
  handler = "watchlist"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/watchlist.zip"
  source_code_hash = "${filebase64sha256("../bin/watchlist.zip")}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
      DATA_BUCKET = "${aws_s3_bucket.data.bucket}"
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_watchlist" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.watchlist.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.prod.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "watchlist_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.watchlist.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "watchlist_lambda_logs_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_policy.arn}"
}

# Lambda: rmepisode
# ----------------------------------------

resource "aws_lambda_function" "rmepisode" {
  function_name = "episodic_rmepisode"
  runtime = "go1.x"
  handler = "rmepisode"
  role = "${aws_iam_role.lambda_role.arn}"

  filename = "../bin/rmepisode.zip"
  source_code_hash = "${filebase64sha256("../bin/rmepisode.zip")}"

  environment {
    variables = {
      TMDB_API_KEY = "${var.tmdb_api_key}"
      DATA_BUCKET = "${aws_s3_bucket.data.bucket}"
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda_rmepisode" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rmepisode.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.prod.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "rmepisode_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.rmepisode.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy_attachment" "rmepisode_lambda_logs_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_policy.arn}"
}

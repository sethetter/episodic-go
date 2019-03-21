# API and Stage

resource "aws_api_gateway_rest_api" "episodic_api" {
  name        = "episodic_api"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_deployment" "test" {
  depends_on = [
    "aws_api_gateway_resource.twilio",
    "aws_api_gateway_resource.twilio_proxy",
    "aws_api_gateway_integration.twilio_proxy_integration",
    "aws_api_gateway_resource.watchlist",
    "aws_api_gateway_resource.watchlist_proxy",
    "aws_api_gateway_integration.watchlist_proxy_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  stage_name = "test"
  variables {
    deployed_at = "${var.deployed_at}"
  }
}

# twilio resource
# ----------------------------------------

resource "aws_api_gateway_resource" "twilio" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.episodic_api.root_resource_id}"
  path_part   = "twilio"
}

resource "aws_api_gateway_resource" "twilio_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_resource.twilio.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "twilio_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.twilio_proxy.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "twilio_proxy_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.twilio_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.twilio_proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.twilio.invoke_arn}"
}

# watchlist resource
# ----------------------------------------

resource "aws_api_gateway_resource" "watchlist" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.episodic_api.root_resource_id}"
  path_part   = "watchlist"
}

resource "aws_api_gateway_resource" "watchlist_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_resource.watchlist.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "watchlist_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.watchlist_proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "watchlist_proxy_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.watchlist_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.watchlist_proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.watchlist.invoke_arn}"
}


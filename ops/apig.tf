# API and Stage

resource "aws_api_gateway_rest_api" "episodic_api" {
  name        = "episodic_api"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_deployment" "test" {
  depends_on = [
    "aws_api_gateway_resource.twilio",
    "aws_api_gateway_resource.twilio_proxy",
    "aws_api_gateway_integration.twilio_proxy_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  stage_name = "test"
}

# Twilio Resource

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


# API and Stage

resource "aws_api_gateway_rest_api" "EpisodicAPI" {
  name        = "EpisodicAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_deployment" "EpisodicAPITest" {
  depends_on = [
    # "aws_api_gateway_resource.proxy",
    "aws_api_gateway_resource.twilio",
    "aws_api_gateway_integration.twilio_post_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  stage_name = "test"
}

# Twilio Resource

resource "aws_api_gateway_resource" "twilio" {
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.EpisodicAPI.root_resource_id}"
  path_part   = "twilio"
}

# resource "aws_api_gateway_resource" "proxy" {
#   rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
#   parent_id   = "${aws_api_gateway_rest_api.EpisodicAPI.root_resource_id}"
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "proxy" {
#   rest_api_id   = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
#   resource_id   = "${aws_api_gateway_resource.proxy.id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "twilio_proxy_integration" {
#   rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
#   resource_id = "${aws_api_gateway_method.proxy.resource_id}"
#   http_method = "${aws_api_gateway_method.proxy.http_method}"
#   integration_http_method = "POST"
#   type = "AWS_PROXY"
#   uri = "${aws_lambda_function.twilio.invoke_arn}"
# }

resource "aws_api_gateway_method" "twilio_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id   = "${aws_api_gateway_resource.twilio.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "twilio_post_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.EpisodicAPI.id}"
  resource_id = "${aws_api_gateway_method.twilio_post.resource_id}"
  http_method = "${aws_api_gateway_method.twilio_post.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.twilio.invoke_arn}"
}

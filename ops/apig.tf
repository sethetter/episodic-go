# API, and domain
# ----------------------------------------

resource "aws_api_gateway_rest_api" "episodic_api" {
  name        = "episodic_api"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_domain_name" "episodic_domain" {
  certificate_arn = "${data.aws_acm_certificate.domain.arn}"
  domain_name = "episodic-api.n0pe.lol"
}

resource "aws_api_gateway_base_path_mapping" "episodic_prod" {
  api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  stage_name = "${aws_api_gateway_deployment.prod.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.episodic_domain.domain_name}"
}

resource "aws_route53_record" "episodic_domain" {
  name = "${aws_api_gateway_domain_name.episodic_domain.domain_name}"
  type = "A"
  zone_id = "${data.aws_route53_zone.domain.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${aws_api_gateway_domain_name.episodic_domain.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.episodic_domain.cloudfront_zone_id}"
  }
}

# deployment
# ----------------------------------------

resource "aws_api_gateway_deployment" "prod" {
  depends_on = [
    "aws_api_gateway_resource.twilio",
    "aws_api_gateway_resource.twilio_proxy",
    "aws_api_gateway_integration.twilio_proxy_integration",
    "aws_api_gateway_resource.watchlist",
    "aws_api_gateway_resource.watchlist_proxy",
    "aws_api_gateway_integration.watchlist_proxy_integration",
    "aws_api_gateway_resource.rmepisode",
    "aws_api_gateway_resource.rmepisode_proxy",
    "aws_api_gateway_integration.rmepisode_proxy_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  stage_name = "prod"
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

resource "aws_api_gateway_method" "twilio_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.twilio.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "twilio_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.twilio_proxy.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "twilio_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.twilio_root.resource_id}"
  http_method = "${aws_api_gateway_method.twilio_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.twilio.invoke_arn}"
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

resource "aws_api_gateway_method" "watchlist_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.watchlist.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "watchlist_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.watchlist_proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "watchlist_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.watchlist_root.resource_id}"
  http_method = "${aws_api_gateway_method.watchlist_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.watchlist.invoke_arn}"
}

resource "aws_api_gateway_integration" "watchlist_proxy_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.watchlist_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.watchlist_proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.watchlist.invoke_arn}"
}

# rmepisode resource
# ----------------------------------------

resource "aws_api_gateway_resource" "rmepisode" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.episodic_api.root_resource_id}"
  path_part   = "rmepisode"
}

resource "aws_api_gateway_resource" "rmepisode_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  parent_id   = "${aws_api_gateway_resource.rmepisode.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "rmepisode_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.rmepisode.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "rmepisode_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id   = "${aws_api_gateway_resource.rmepisode_proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rmepisode_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.rmepisode_root.resource_id}"
  http_method = "${aws_api_gateway_method.rmepisode_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.rmepisode.invoke_arn}"
}

resource "aws_api_gateway_integration" "rmepisode_proxy_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.episodic_api.id}"
  resource_id = "${aws_api_gateway_method.rmepisode_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.rmepisode_proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.rmepisode.invoke_arn}"
}


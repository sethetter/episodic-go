# This portion of the tf assumes you have a wildcard certificate configured
# in AWS for the domain set.
data "aws_acm_certificate" "domain" {
  domain      = "*.${var.base_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "domain" {
  name = "${var.base_domain}."
}

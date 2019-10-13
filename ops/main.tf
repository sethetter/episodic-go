provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

output "apig_url" {
  value = "${aws_api_gateway_deployment.prod.invoke_url}"
}

output "web_bucket" {
  value = "${aws_s3_bucket.episodic_web.bucket}"
}

output "web_url" {
  value = "${aws_s3_bucket.episodic_web.website_endpoint}"
}

output "twilio_number" {
  value = "${var.twilio_phone_number}"
}

output "web_cfdist" {
  value = "${aws_cloudfront_distribution.episodic_web.id}"
}

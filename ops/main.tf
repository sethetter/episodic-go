provider "aws" {
  profile = "default"
  region = "${var.aws_region}"
}

provider "twilio" {
  account_sid = "${var.twilio_account_sid}"
  auth_token = "${var.twilio_auth_token}"
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
  value = "${twilio_phonenumber.prod.phone_number}"
}

output "web_cfdist" {
  value = "${aws_cloudfront_distribution.episodic_web.id}"
}

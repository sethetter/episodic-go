provider "aws" {
  profile = "default"
  region = "${var.aws_region}"
}

provider "twilio" {
  account_sid = "${var.twilio_account_sid}"
  auth_token = "${var.twilio_auth_token}"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.test.invoke_url}"
}

output "web_bucket" {
  value = "${aws_s3_bucket.web.bucket}"
}

output "web_url" {
  value = "${aws_s3_bucket.web.website_endpoint}"
}

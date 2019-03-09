provider "aws" {
  profile = "default"
  region = "${var.aws_region}"
}

provider "twilio" {
  account_sid = "${var.twilio_account_sid}"
  auth_token = "${var.twilio_auth_token}"
}

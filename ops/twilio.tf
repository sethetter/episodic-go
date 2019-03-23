# Twilio Number

resource "twilio_phonenumber" "prod" {
  name = "episodic-prod"
  sms_method = "POST"
  sms_url = "${aws_api_gateway_deployment.prod.invoke_url}/${aws_api_gateway_resource.twilio.path_part}"
  location {
    region = "KS"
    near_number = "+13164615633"
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "episodic-data"
  acl = "private"
}

resource "aws_iam_policy" "lambda_data_s3_policy" {
  name = "lambda_data_s3_policy"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.data.arn}/*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_data_s3_role_attachment" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_data_s3_policy.arn}"
}

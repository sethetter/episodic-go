resource "aws_s3_bucket" "web" {
  bucket = "episodic-web"
  acl = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::episodic-web/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
  }
}


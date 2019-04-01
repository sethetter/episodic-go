resource "aws_s3_bucket" "episodic_web" {
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

resource "aws_cloudfront_distribution" "episodic_web" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = "${aws_s3_bucket.episodic_web.website_endpoint}"
    origin_id   = "episodic-web"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      # Why are these necessary?!
      https_port = "443"
      origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases = ["episodic.${var.base_domain}"]

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.domain.arn}"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    target_origin_id = "episodic-web"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
}

resource "aws_route53_record" "episodic_web" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name = "episodic.${var.base_domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.episodic_web.domain_name}"
    zone_id = "${aws_cloudfront_distribution.episodic_web.hosted_zone_id}"
    evaluate_target_health = false
  }
}

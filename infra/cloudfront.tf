resource "aws_cloudfront_distribution" "main" {
  is_ipv6_enabled = true
  http_version    = "http2and3"

  origin {
    origin_id   = "origin-${local.resources_name}"
    domain_name = data.aws_s3_bucket.source.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "User-Agent"
      value = local.user_agent
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = local.has_custom_domain ? [var.service_domain_name] : []

  default_cache_behavior {
    target_origin_id = "origin-${local.resources_name}"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.issued.arn
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}


resource "aws_route53_record" "cloudfront" {
  zone_id = var.route53id
  name    = var.service_domain_name
  type    = "CNAME"
  ttl     = 5
  records = [aws_cloudfront_distribution.main.domain_name]
}
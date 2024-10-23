# Create the access origin control that will be used in creating our cloudfront distribution with s3 origin
resource "aws_cloudfront_origin_access_control" "assign-oac" {
  name                              = var.oac-name
  description                       = "An origin access control with s3 origin domain for cloudfront"
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}

# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = var.cdn-domain_name-and-origin_id
    origin_id                = var.cdn-domain_name-and-origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.assign-oac.id
  }

  default_cache_behavior {
    compress = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = [ "GET", "HEAD" ]
    cached_methods         = [ "GET", "HEAD" ]
    target_origin_id       = var.cdn-domain_name-and-origin_id
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward    = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  aliases             = [var.domain_name, "tf.${var.domain_name}"]
}
resource "aws_s3_bucket" "main" {
  for_each = var.buckets
  bucket   = each.value.bucket_name
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  for_each = var.buckets
  
  bucket = aws_s3_bucket.main[each.key].id

  index_document {
    suffix = each.value.index_document
  }

  error_document {
    key = each.value.error_document
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main[each.key].arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_control" "main" {
  for_each = var.buckets

  name                              = each.value.bucket_name
  description                       = "Origin access control for ${each.value.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  for_each = var.buckets

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = each.value.index_document
  aliases             = each.value.domain_names
  price_class         = each.value.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.main[each.key].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main[each.key].id
    origin_id                = "S3-${each.value.bucket_name}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${each.value.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress              = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }



  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
  
  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.project_name}-${each.key}-distribution"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
} 
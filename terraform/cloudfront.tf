locals {
  s3_origin_id = "myS3Origin"
  # my_domain    = "mydomain.com"
}

resource "aws_cloudfront_origin_access_control" "pos_center_cloudfront_s3_oac" {
  name                              = "pos-center-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.pos_center.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.pos_center_cloudfront_s3_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront with Lambda API and S3 static frontend"
  default_root_object = "index.html"

  # aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]

  # ordered_cache_behavior {
  #   path_pattern     = "/api/*"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = local.lambda_origin_id

  #   forwarded_values {
  #     query_string = true
  #     headers      = ["Authorization", "Content-Type"]

  #     cookies {
  #       forward = "all"
  #     }
  #   }

  #   min_ttl                = 0
  #   default_ttl            = 0 # ไม่แคชผลลัพธ์ API เป็นค่าเริ่มต้น
  #   max_ttl                = 0
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["TH"]
    }
  }

  tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

locals {
  s3_origin_id     = "myS3Origin"
  lambda_origin_id = "portalServiceLambdaOrigin"
  # function_url = "https://xxxx.lambda-url.ap-southeast-1.on.aws/" -> เอาแค่ domain
  lambda_origin_domain = split("/", aws_lambda_function_url.portal_service.function_url)[2]
  # my_domain    = "mydomain.com"
}

# managed policies ของ AWS สำหรับ API: ไม่ cache และส่งทุกอย่าง (cookie, query, header) ยกเว้น Host ไปให้ Lambda
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_origin_access_control" "pos_center_cloudfront_s3_oac" {
  name                              = "pos-center-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "viewer_request" {
  name    = "pos-center-viewer-request"
  runtime = "cloudfront-js-2.0"
  comment = "SPA rewrite to index.html"
  publish = true
  code    = file("${path.module}/functions/viewer-request.js")
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.pos_center.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.pos_center_cloudfront_s3_oac.id
    origin_id                = local.s3_origin_id
  }

  # portal-service บน Lambda Function URL
  origin {
    domain_name = local.lambda_origin_domain
    origin_id   = local.lambda_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # app ปฏิเสธ request ที่ไม่มี header นี้ -> ยิงตรงเข้า Function URL ไม่ได้
    custom_header {
      name  = "x-origin-secret"
      value = var.origin_secret
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront with Lambda API and S3 static frontend"
  default_root_object = "index.html"

  # aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]

  # /api/* -> Lambda (path ส่งต่อไปตรงๆ เพราะ route ของ portal-service เป็น /api/v1/...)
  # ไม่ผูก viewer-request function เพราะ SPA rewrite จะทำให้ /api/... กลายเป็น /index.html
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.lambda_origin_id

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
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

resource "aws_s3_bucket" "pos_center" {
  bucket        = var.bucket_name
  force_destroy = true # force delete event if have some file/object

  tags = {
    Team        = var.team
    Project     = var.project
    Environment = var.environment
  }
}



# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------







resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.pos_center.id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.pos_center.arn}/*"
        "Condition" : {
          "ArnLike" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

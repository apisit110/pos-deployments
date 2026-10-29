output "cloudfront_distribution_id" {
  description = "ใช้ตั้งค่า CLOUDFRONT_DISTRIBUTION_ID ใน pipelines/pos-center/Jenkinsfile"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
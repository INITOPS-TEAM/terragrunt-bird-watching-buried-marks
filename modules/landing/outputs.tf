output "s3_bucket_name" {
  value       = aws_s3_bucket.landing.id
  description = "Name of the S3 bucket"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.landing.id
  description = "ID of the CloudFront distribution"
}
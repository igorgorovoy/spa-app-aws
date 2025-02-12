output "cloudfront_domains" {
  value = {
    for k, v in aws_cloudfront_distribution.main : k => v.domain_name
  }
}

output "bucket_names" {
  value = {
    for k, v in aws_s3_bucket.main : k => v.id
  }
}

output "distribution_ids" {
  value = {
    for k, v in aws_cloudfront_distribution.main : k => v.id
  }
} 
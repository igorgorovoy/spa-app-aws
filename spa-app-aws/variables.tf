variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "buckets" {
  type = map(object({
    bucket_name            = string
    index_document        = string
    error_document       = string
    domain_names         = list(string)
    cloudfront_price_class = string
  }))
  description = "Map of bucket configurations"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of ACM certificate for CloudFront"
} 
# spa-app-aws

## Terraform module code example for article for community aws. Provision infrastructure on aws for single page application.


```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//spa-app-aws"
}

dependency "acm" {
  config_path = "../acm"
}

inputs = {
  buckets = {
    app = {
      bucket_name            = "spa-app1-aws.placebo.io"
      index_document        = "index.html"
      error_document       = "error.html"
      domain_names         = ["aspa-app1-aws.placebo.ioy"]
      cloudfront_price_class = "PriceClass_100"
    }
    admin = {
      bucket_name            = "spa-app2-aws.placebo.io"
      index_document        = "index.html"
      error_document       = "error.html"
      domain_names         = ["spa-app2-aws.placebo.io"]
      cloudfront_price_class = "PriceClass_100"
    }
  }
  certificate_arn = dependency.acm.outputs.certificate_arn
} 
```

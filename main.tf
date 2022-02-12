module "acm_request_certificate" {
  source                            = "cloudposse/acm-request-certificate/aws"
  version                           = "0.16.0" # https://github.com/cloudposse/terraform-aws-acm-request-certificate/tags
  domain_name                       = "cloudposse.venkatamutyala.com"
  process_domain_validation_options = true
  wait_for_certificate_issued       = true
  ttl                               = "300"
  subject_alternative_names         = ["cloudposse.venkatamutyala.com", "*.cloudposse.venkatamutyala.com"]
}

module "cdn" {
  source  = "cloudposse/cloudfront-s3-cdn/aws"
  version = "0.82.2" # https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn/tags

  namespace                         = "eg"
  stage                             = "prod"
  name                              = "venkata-app"
  aliases                           = ["s3.cloudposse.venkatamutyala.com"]
  dns_alias_enabled                 = true
  parent_zone_name                  = "cloudposse.venkatamutyala.com"
  cloudfront_access_logging_enabled = false
  allow_ssl_requests_only           = true
  allowed_methods                   = ["HEAD", "GET"]
  wait_for_deployment               = true
  acm_certificate_arn               = module.acm_request_certificate.arn
}

resource "aws_s3_bucket_object" "index" {
  bucket       = module.cdn.s3_bucket
  key          = "index.html"
  source       = "app/index.html"
  content_type = "text/html"
  depends_on   = [module.cdn]
}
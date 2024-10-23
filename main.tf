# Create S3 bucket, upload objects into the bucket and set bucket policy.
module "s3-bucket" {
  source = "./Modules/s3-bucket"
  bucket-name = var.bucket-name
  web-assets-path = var.web-assets-path
}

# Create and validate TLS/SSL certificate
module "certificate" {
  source = "./Modules/certificate"
  domain_name = var.domain_name
  subject_alternative_names  = ["tf.${var.domain_name}"]
}

# Create OAC and cloudfront distribution, 
module "cloudfront" {
  source = "./Modules/cloudfront"
  domain_name = var.domain_name
  cdn-domain_name-and-origin_id = module.s3-bucket.bucket_regional_domain_name
  acm_certificate_arn = module.certificate.cert-arn
  depends_on = [ module.route53 ]
}

# Retrieve details of the hosted zone from AWS, create dns records for certificate validation, and create A record.
module "route53" {
  source = "./Modules/route53"
  domain_name = var.domain_name
  domain_validation_options = module.certificate.domain_validation_options
  certificate_arn = module.certificate.cert-arn
}

# Create an alias to point the cloudfront cdn to our domain name.
# module "alias" {
#   source = "./Modules/alias"
#   domain_name = var.domain_name
#   cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
#   cloudfront-zone-id = module.cloudfront.cloudfront_hosted-zone_id
#   depends_on = [ module.cloudfront ]
# }

# Run terraform apply --target module.certificate first
# Then run terraform apply to build the rest.
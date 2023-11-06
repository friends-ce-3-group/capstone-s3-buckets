output "s3_bucket_website_domain_name" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

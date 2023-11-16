output "s3_bucket_website_domain_name" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

resource "local_file" "write_url" {
  content  = "S3_BUCKET_WEBSITE_URL=${aws_s3_bucket_website_configuration.website.website_endpoint}"
  filename = "${path.module}/s3_bucket_website_url.dat"
}
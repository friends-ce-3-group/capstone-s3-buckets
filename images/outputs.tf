output "s3_bucket_images_domain_name" {
  value = aws_s3_bucket.s3_images.bucket_domain_name
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}


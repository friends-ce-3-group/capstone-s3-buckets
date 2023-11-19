output "s3_bucket_images_domain_name" {
  value = aws_s3_bucket.s3_images.bucket_domain_name
}

output "s3_bucket_images_regional_domain_name" {
  value = aws_s3_bucket.s3_images.bucket_regional_domain_name
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.api-stage.invoke_url
}

output "api_gateway_stage_arn" {
  value = aws_api_gateway_stage.api-stage.arn
}


resource "local_file" "write_images_url" {
  content  = "S3_BUCKET_IMAGES_URL=${aws_s3_bucket.s3_images.bucket_regional_domain_name}"
  filename = "${path.module}/s3_bucket_images_url.dat"
}

resource "local_file" "write_upload_images_url" {
  content  = "API_GATEWAY_UPLOAD_IMAGES_URL=${aws_api_gateway_stage.api-stage.invoke_url}"
  filename = "${path.module}/api_gateway_upload_images_url.dat"
}

resource "local_file" "write_upload_images_arn" {
  content  = "API_GATEWAY_UPLOAD_IMAGES_ARN=${aws_api_gateway_stage.api-stage.arn}"
  filename = "${path.module}/api_gateway_upload_images_arn.dat"
}
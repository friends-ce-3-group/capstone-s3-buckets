resource "aws_s3_bucket" "s3_images" {
  bucket = var.proj_name
  tags = {
    Name = var.proj_name
  }
}
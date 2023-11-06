resource "aws_s3_bucket" "s3_website" {
  bucket = var.proj_name
  tags = {
    Name = var.proj_name
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.s3_website.id
  index_document {
    suffix = "index.html"
  }
}

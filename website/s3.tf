resource "aws_s3_bucket" "s3_website" {
  bucket = var.proj_name
  tags = {
    Name = var.proj_name
  }
}

#resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
#  bucket = aws_s3_bucket.s3_website.id
#  rule {
#    object_ownership = "BucketOwnerPreferred"
#  }
#}

#resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#  depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_ownership_controls]
#  bucket = aws_s3_bucket.s3_website.id
#  acl = "private"
#}


resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.s3_website.id
  index_document {
    suffix = "index.html"
  }
}

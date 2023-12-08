resource "aws_s3_bucket" "s3_website" {
  bucket        = var.proj_name
  force_destroy = true
  tags = {
    Name = var.proj_name
  }
}

// S3 -> Permissions -> Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "block_public_options" {
  bucket = aws_s3_bucket.s3_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

// S3 -> Permissions -> Object Ownership
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.block_public_options]
}

// S3 -> Permissions -> Access control list (ACL)
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.s3_website.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_website.id
  versioning_configuration {
    status = "Enabled"
  }
}

// S3 -> Permissions -> Bucket Policy
data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"] //[TODO] change principal to cloudfront 
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_website.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "all_access_from_cloudfront" {
  bucket     = aws_s3_bucket.s3_website.id
  policy     = data.aws_iam_policy_document.allow_access_from_cloudfront.json
  depends_on = [aws_s3_bucket_public_access_block.block_public_options]
}

// S3 -> Properties -> Static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.s3_website.id
  index_document {
    suffix = "index.html"
  }
}

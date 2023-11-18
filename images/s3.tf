resource "aws_s3_bucket" "s3_images" {
  bucket = var.proj_name
  tags = {
    Name = var.proj_name
  }
}

resource "aws_s3_object" "originals" {
  bucket = aws_s3_bucket.s3_images.id
  key    = "${var.originals_folder}/"
}

resource "aws_s3_object" "thumbnails" {
  bucket = aws_s3_bucket.s3_images.id
  key    = "${var.thumbnails_folder}/"
}

resource "aws_s3_object" "resized" {
  bucket = aws_s3_bucket.s3_images.id
  key    = "${var.resized_folder}/"
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["arn:aws:s3:::${var.proj_name}/*"]

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::255945442255:distribution"]
    }
  }
}

resource "aws_s3_bucket_policy" "images_bucket_policy" {
  bucket = aws_s3_bucket.s3_images.id
  policy = data.aws_iam_policy_document.cloudfront.json
}

resource "aws_s3_bucket_notification" "eventbridge_notification" {
  bucket      = aws_s3_bucket.s3_images.id
  eventbridge = true
}
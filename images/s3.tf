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
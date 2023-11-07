# create aws_iam_role for api_gateway
resource "aws_iam_role" "api_gateway_iam_role" {
  name               = "${var.proj_name}-api_gateway-iam_role"
  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

# create aws_iam_policy for s3 buckets
data "aws_iam_policy_document" "s3_images_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.s3_images.arn}/${var.originals_folder}/*",
      "${aws_s3_bucket.s3_images.arn}/${var.thumbnails_folder}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_images_policy" {
  name        = "${var.proj_name}-iam_policy"
  description = "iam policy to control s3 bucket accesses"
  policy      = data.aws_iam_policy_document.s3_images_policy_document.json
}

# attach S3 iam policy to API_Gateway iam role
resource "aws_iam_role_policy_attachment" "api_gateway_role_s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_images_policy.arn
  role       = aws_iam_role.api_gateway_iam_role.name
}
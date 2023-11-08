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

# create a api gateway with the type of REST API
resource "aws_api_gateway_rest_api" "image_upload_api" {
  name = "${var.proj_name}-api-gateway"
  binary_media_types = [
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/gif"
  ]
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# create a resource path for the REST API /{bucket}/
resource "aws_api_gateway_resource" "bucket" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  parent_id   = aws_api_gateway_rest_api.image_upload_api.root_resource_id
  path_part   = "{bucket}"
}

# create a resource path for the REST API /{bucket}/{folder}
resource "aws_api_gateway_resource" "folder" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  parent_id   = aws_api_gateway_resource.bucket.id
  path_part   = "{folder}"
}

# create a resource path for the REST API /{bucket}/{folder}/{filename}
resource "aws_api_gateway_resource" "filename" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  parent_id   = aws_api_gateway_resource.folder.id
  path_part   = "{filename}"
}

#####################################################################
# create a PUT method for the REST API
#####################################################################
resource "aws_api_gateway_method" "put_method" {
  rest_api_id   = aws_api_gateway_rest_api.image_upload_api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.bucket"   = true,
    "method.request.path.folder"   = true,
    "method.request.path.filename" = true,
  }
}

# configure integration between api gateway and s3
resource "aws_api_gateway_integration" "s3_integration" {
  type                    = "AWS"
  rest_api_id             = aws_api_gateway_rest_api.image_upload_api.id
  resource_id             = aws_api_gateway_resource.filename.id
  http_method             = aws_api_gateway_method.put_method.http_method
  integration_http_method = "PUT"
  credentials             = aws_iam_role.api_gateway_iam_role.arn
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/{bucket}/{folder}/{filename}"

  request_parameters = {
    "integration.request.path.bucket"   = "method.request.path.bucket",
    "integration.request.path.folder"   = "method.request.path.folder",
    "integration.request.path.filename" = "method.request.path.filename",
  }

  depends_on = [aws_api_gateway_method.put_method]

}

resource "aws_api_gateway_integration_response" "IntegrationResponse200" {
  depends_on  = [aws_api_gateway_integration.s3_integration]
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = aws_api_gateway_method_response.Status200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}


resource "aws_api_gateway_method_response" "Status200" {
  depends_on  = [aws_api_gateway_method.put_method]
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }

}

#####################################################################
# Configurations related to enabling CORS - add the OPTIONS method
#####################################################################
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.image_upload_api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_method_response.options_200]
}


# Deploy api gateway to dev environment
resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on  = [aws_api_gateway_integration.s3_integration]
  rest_api_id = aws_api_gateway_rest_api.image_upload_api.id
  stage_name  = "dev"
}

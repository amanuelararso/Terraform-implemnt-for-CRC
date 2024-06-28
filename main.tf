terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}
resource "random_pet" "trailingName" {
  length = 2
  
}
#  creating S3 bucket 
resource "aws_s3_bucket" "website-bucket" {
  bucket = "website-bucket-${random_pet.trailingName.id}"
  
}
# config of static website
resource "aws_s3_bucket_website_configuration" "s3webconfig" {

  bucket = aws_s3_bucket.website-bucket.id
  index_document {
    suffix = "index.html"
  }
  
}

# allowing access to the bucket files (html, css, image), required to host website
resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.website-bucket.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

# attaching policy to bucket
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.website-bucket.id
  policy = data.aws_iam_policy_document.allow_public_read_data.json
  depends_on = [ aws_s3_bucket_public_access_block.allow_public_access ]
}
data "aws_iam_policy_document" "allow_public_read_data" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.website-bucket.arn}/*",
    ]
  }
}

resource "random_pet" "code_pet" {
  length = 2
  
}
resource "aws_s3_bucket" "lambda_code_repo" {
  bucket = "lambda-code-repo-${random_pet.code_pet.id}"
}

#CLOUDFRONT
resource "aws_cloudfront_distribution" "web_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.website-bucket.bucket_domain_name}"
    origin_id   = aws_s3_bucket.website-bucket.website_endpoint
   
  }
  enabled = true
  default_root_object = "index.html"
  aliases = [ "jote.dev" ]
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website-bucket.website_endpoint    
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:478991354801:certificate/c3b94d06-b284-411b-ae78-02bc51cc9f5d" #from cert manager
    ssl_support_method = "sni-only"
  }  
  depends_on = [ aws_s3_bucket.website-bucket ]
}

# ROUTE 53
resource "aws_route53_zone" "jote_zone" {
  name = "jote.dev" 
}
  
  # data for policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# lambda requires role
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
# data for the py file, 
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "visitorCounter.py"
  output_path = "visitorCounter.py.zip"
}

resource "aws_lambda_function" "updateVisitorCounter" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "visitorCounter.py.zip"
  function_name = "update_visitor_count"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  # source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "view-count"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"
  range_key = "count"
  
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name="count"
    type = "N"
  }


  tags = {
    Name        = "dynamodb-table-for-visitor-count"
    Environment = "production"
  }
}

# REST-API
resource "aws_api_gateway_rest_api" "visitorAPI" {
  name = "visitorAPI"
}

resource "aws_api_gateway_resource" "apiResource" {
  parent_id   = aws_api_gateway_rest_api.visitorAPI.root_resource_id
  path_part   = "resource_path"
  rest_api_id = aws_api_gateway_rest_api.visitorAPI.id
}

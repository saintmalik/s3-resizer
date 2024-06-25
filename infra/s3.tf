data "aws_s3_bucket" "source" {
  bucket = var.source_bucket
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = data.aws_s3_bucket.source.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      protocol         = "https"
      host_name        = replace(aws_apigatewayv2_api.main.api_endpoint, "https://", "")
      http_redirect_code = "307"
      replace_key_prefix_with  = "default/${aws_lambda_function.main.function_name}/?path="
    }
  }
}

# Add bucket policy
resource "aws_s3_bucket_policy" "main" {
  bucket = data.aws_s3_bucket.source.bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# Your existing policy document
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.source.bucket}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"
      values   = [local.user_agent]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
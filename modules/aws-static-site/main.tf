resource "aws_s3_bucket" "site" {
  bucket = "${var.name}-${var.environment}-${random_id.suffix.hex}"

  tags = local.common_tags
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id

  depends_on = [
    aws_s3_bucket_public_access_block.site
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = var.index_html_path
  content_type = "text/html"
  etag         = filemd5(var.index_html_path)

  tags = local.common_tags
}

locals {
  common_tags = {
    application = var.name
    environment = var.environment
    cost_center = var.cost_center
    owner       = var.owner
    managed_by  = "terraform"
  }
}

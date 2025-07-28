data "aws_caller_identity" "account_details" {
}

locals {
  caller_arn    = data.aws_caller_identity.account_details.arn
  is_role       = can(regex("arn:aws:iam::\\d+:role/([^/]+)", local.caller_arn))
  effective_arn = local.is_role ? regex("^(.*)/[^/]+$", local.caller_arn)[0] : local.caller_arn
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = var.bucket_name
  region = var.region
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_public_access_block" "block_state_access" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "state_bucket_policy" {
  bucket = aws_s3_bucket.state_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformAccess"
        Effect = "Allow"
        Principal = {
          "AWS" = [local.effective_arn]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:Get*"
        ]
        Resource = [
          "${aws_s3_bucket.state_bucket.arn}",  # For List Bucket
          "${aws_s3_bucket.state_bucket.arn}/*" # For all other operations
        ]
    }]
  })
}
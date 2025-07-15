data "aws_caller_identity" "account_details" {
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "lb-80-app"
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
          "AWS" = [data.aws_caller_identity.account_details.arn] # We can add a role here as well
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.state_bucket.arn}",  # For List Bucket
          "${aws_s3_bucket.state_bucket.arn}/*" # For all other operations
        ]
    }]
  })
}
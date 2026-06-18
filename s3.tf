resource "aws_s3_bucket" "assets" {
  bucket = "phase1-assets-${data.aws_caller_identity.current.account_id}"

  tags = { Name = "phase1-assets" }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
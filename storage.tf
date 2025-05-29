#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# Create S3 bucket for Lambda source code
resource "aws_s3_bucket" "lambda_source" {
  bucket        = "${var.name}-lambda-source-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  #checkov:skip=CKV_AWS_18: AWS Access logging not enabled on S3 buckets
  #checkov:skip=CKV_AWS_144: Region replication not enabled on S3 bucket
  #checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
  # These security controls are suppressed as this bucket is only used temporarily for Lambda code signing
  # and is not intended for long-term storage or public access. The bucket has other security measures
  # like encryption and public access blocking enabled.
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# Enable versioning on the source S3 bucket (required for signing)
resource "aws_s3_bucket_versioning" "lambda_source" {
  bucket = aws_s3_bucket.lambda_source.id
  versioning_configuration {
    status = "Enabled"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "lambda_source" {
  bucket                  = aws_s3_bucket.lambda_source.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_source" {
  bucket = aws_s3_bucket.lambda_source.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encrypt_storage.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "lambda_source" {
  bucket = aws_s3_bucket.lambda_source.id

  rule {
    id     = "abort-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

}
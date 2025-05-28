#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# Create S3 bucket for Lambda source code
resource "aws_s3_bucket" "lambda_source" {
  bucket        = "${var.name}-lambda-source-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# Enable versioning on the source S3 bucket (required for signing)
resource "aws_s3_bucket_versioning" "lambda_source" {
  bucket = aws_s3_bucket.lambda_source.id
  versioning_configuration {
    status = "Enabled"
  }
}
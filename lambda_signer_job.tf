#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# Create S3 bucket for Lambda source code
resource "aws_s3_bucket" "lambda_source" {
  bucket_prefix = "${var.name}-lambda-source-${data.aws_caller_identity.current.account_id}"
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
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# Create S3 bucket for Lambda source code
resource "aws_s3_bucket" "lambda_destination" {
  bucket_prefix = "${var.name}-lambda-destination-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# Enable versioning on the source S3 bucket (required for signing)
resource "aws_s3_bucket_versioning" "lambda_destination" {
  bucket = aws_s3_bucket.lambda_destination.id
  versioning_configuration {
    status = "Enabled"
  }
}
#https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# Sign the Lambda function code using AWS Signer
#https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# Sign the Lambda function code using AWS Signer
resource "null_resource" "sign_lambda_code" {
  depends_on = [
    aws_s3_object.lambda_zip,
    aws_signer_signing_profile.lambda_signing_profile
  ]

  # Use AWS Signer with S3 source and destination - correct syntax
  provisioner "local-exec" {
    command = "aws signer start-signing-job --source '{\"s3\":{\"bucketName\":\"${aws_s3_bucket.lambda_source.bucket}\",\"key\":\"lambda_function.zip\"}}' --destination '{\"s3\":{\"bucketName\":\"${aws_s3_bucket.lambda_destination.bucket}\",\"key\":\"lambda_function_signed.zip\"}}' --profile-name ${aws_signer_signing_profile.lambda_signing_profile.name}"
  }

  triggers = {
    source_code_hash = data.archive_file.python_file.output_base64sha256
  }
}

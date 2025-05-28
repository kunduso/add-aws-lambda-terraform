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
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# Create S3 bucket for Lambda source code
resource "aws_s3_bucket" "lambda_destination" {
  bucket        = "${var.name}-lambda-destination-${data.aws_caller_identity.current.account_id}"
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
resource "null_resource" "sign_lambda_code" {
  depends_on = [
    aws_s3_object.lambda_zip,
    aws_signer_signing_profile.lambda_signing_profile,
    aws_s3_bucket.lambda_source,
    aws_s3_bucket.lambda_destination
  ]

  # Use AWS Signer with S3 source and destination - correct syntax
  provisioner "local-exec" {
    
    command = <<EOT
      # Get the version ID of the uploaded object
      VERSION_ID=$(aws s3api list-object-versions --bucket ${aws_s3_bucket.lambda_source.bucket} --prefix lambda_function.zip --query 'Versions[0].VersionId' --output text)
      
      echo "Object version ID: $VERSION_ID"
      
      # Use the actual version ID in the signing job
      JOB_ID=$(aws signer start-signing-job \
        --source '{"s3":{"bucketName":"${aws_s3_bucket.lambda_source.bucket}","key":"lambda_function.zip","version":"'$VERSION_ID'"}}' \
        --destination '{"s3":{"bucketName":"${aws_s3_bucket.lambda_destination.bucket}","prefix":"signed/"}}' \
        --profile-name ${aws_signer_signing_profile.lambda_signing_profile.name} \
        --query 'jobId' --output text)
      
      echo "Signing job ID: $JOB_ID"
      
      # Wait for job to complete if we got a job ID
      if [ ! -z "$JOB_ID" ]; then
        aws signer wait successful-signing-job --job-id $JOB_ID
        
        # List files in destination bucket
        echo "Files in destination bucket:"
        aws s3 ls s3://${aws_s3_bucket.lambda_destination.bucket} --recursive
      fi
    EOT
  }

  triggers = {
    source_code_hash = data.archive_file.python_file.output_base64sha256
  }
}
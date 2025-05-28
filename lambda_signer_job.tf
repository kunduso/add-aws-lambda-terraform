# Sign the Lambda function code using AWS Signer
resource "null_resource" "sign_lambda_code" {
  depends_on = [
    data.archive_file.python_file,
    aws_signer_signing_profile.lambda_signing_profile
  ]

  # Use standard shell for Linux
  provisioner "local-exec" {
    command = "aws signer start-signing-job --source s3=bucket=${var.name}-lambda-code,key=lambda_function.zip --destination s3=bucket=${var.name}-lambda-code,key=lambda_function_signed.zip --profile-name ${aws_signer_signing_profile.lambda_signing_profile.name}"
  }

  triggers = {
    source_code_hash = data.archive_file.python_file.output_base64sha256
  }
}
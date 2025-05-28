# Generate a random string to use as a suffix
#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/signer_signing_profile
resource "aws_signer_signing_profile" "lambda_signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
  name        = "${replace(var.name, "-", "_")}_lambda_signing_profile_${random_string.suffix.result}"
  signature_validity_period {
    value = 135
    type  = "MONTHS"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_code_signing_config
resource "aws_lambda_code_signing_config" "configuration" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.lambda_signing_profile.version_arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
  description = "Code signing configuration for ${var.name} Lambda function"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/signer_signing_job
resource "aws_signer_signing_job" "build_signing_job" {
  profile_name = aws_signer_signing_profile.lambda_signing_profile.name

  source {
    s3 {
      bucket  = aws_s3_bucket.lambda_source.bucket
      key     = aws_s3_object.lambda_zip.key
      version = aws_s3_object.lambda_zip.version_id
    }
  }

  destination {
    s3 {
      bucket = aws_s3_bucket.lambda_source.bucket
      prefix = "signed/"
    }
  }
}
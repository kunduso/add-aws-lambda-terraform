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
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_code_signing_config
resource "aws_lambda_code_signing_config" "configuration" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.lambda_signing_profile.arn]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/signer_signing_profile
resource "aws_signer_signing_profile" "lambda_signing_profile" {
  platform_id = "AWSLambda-SHA384-ECDSA"
  name        = "${replace(var.name, "-", "_")}_lambda_signing_profile"
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
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "parameter" {
  name   = "/${var.name}"
  type   = "SecureString"
  key_id = aws_kms_key.encryption.id
  value  = "1234567890"
}
resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = var.name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.encryption_rest.arn
}
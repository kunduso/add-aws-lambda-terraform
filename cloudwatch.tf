#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = var.name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.encryption_rest.arn
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream
resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name           = "${var.name}-lambda-log-stream"
  log_group_name = aws_cloudwatch_log_group.lambda_log.name
}
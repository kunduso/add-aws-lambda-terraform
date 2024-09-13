#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "dlq" {
  name                              = "${var.name}-lambda-dlq"
  kms_master_key_id                 = aws_kms_key.encryption.arn
  kms_data_key_reuse_period_seconds = 300
}
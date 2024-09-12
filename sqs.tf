#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "dlq" {
  name = "${var.name}-lambda-dlq"
}
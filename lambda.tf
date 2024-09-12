#https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file
data "archive_file" "python_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/"
  output_path = "${path.module}/lambda_function/lambda_function.zip"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "lambda_run" {
  filename         = "${path.module}/lambda_function/lambda_function.zip"
  source_code_hash = data.archive_file.python_file.output_base64sha256
  function_name    = var.name
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.8"
  kms_key_arn      = aws_kms_key.encryption_rest.arn
  logging_config {
    log_format       = "JSON"
    log_group        = aws_cloudwatch_log_group.lambda_log.name
    system_log_level = "INFO"
  }
  environment {
    variables = {
      parameter_name  = aws_ssm_parameter.parameter.name
      log_group_name  = aws_cloudwatch_log_group.lambda_log.name
      log_stream_name = aws_cloudwatch_log_stream.log_stream.name
    }
  }
  #https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  #checkov:skip=CKV_AWS_50: Not applicable in this use case: X-Ray tracing is enabled for Lambda
  #checkov:skip=CKV_AWS_115: Not applicable in this use case: Ensure that AWS Lambda function is configured for function-level concurrent execution limit
  #checkov:skip=CKV_AWS_117: This AWS Lambda function does not require access to anything inside a VPC
  #checkov:skip=CKV_AWS_173: Not applicable in this use case
  #checkov:skip=CKV_AWS_272: Not applicable in this use case: Ensure AWS Lambda function is configured to validate code-signing
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule
resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "${var.name}-lambda-trigger-rule"
  schedule_expression = "rate(10 minutes)"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.lambda_run.arn
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_run.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}
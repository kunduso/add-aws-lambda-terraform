data "archive_file" "python_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/"
  output_path = "${path.module}/lambda_function/lambda_function.zip"
}

resource "aws_lambda_function" "lambda_run" {
  filename         = "${path.module}/lambda_function/lambda_function.zip"
  source_code_hash = data.archive_file.python_file.output_base64sha256
  function_name    = var.name
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.8"
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
}

resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "lambda_trigger_rule"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.lambda_run.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_run.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}
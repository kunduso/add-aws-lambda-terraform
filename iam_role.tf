#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.name}-lambda-policy"
  path        = "/"
  description = "AWS IAM policy for the lambda role."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [aws_ssm_parameter.parameter.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [local.cloudwatch_log_group_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.dlq.arn
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.encryption.arn]
      },
      # Add S3 permissions for accessing signed code
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "${aws_s3_bucket.lambda_source.arn}/*"
        ]
      },
      # Add code signing verification permissions
      {
        Effect = "Allow",
        Action = [
          "lambda:GetCodeSigningConfig",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:VerifyCodeSignature",
          "lambda:*",
          "signer:GetSigningProfile",
          "signer:DescribeSigningJob",
          "signer:*"
        ],
        Resource = "*"
      }
    ]
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_policy_attachement" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
#https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html#configuration-vpc-permissions
#https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaVPCAccessExecutionRole.html
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "managed_vpc_policy_attachement" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
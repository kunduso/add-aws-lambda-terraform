#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "encrypt_storage" {
  enable_key_rotation     = true
  description             = "Key to encrypt S3 bucket in ${var.name}."
  deletion_window_in_days = 7
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "encrypt_storage" {
  name          = "alias/${var.name}-encrypt-storage"
  target_key_id = aws_kms_key.encrypt_storage.key_id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "encrypt_storage_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Create*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    resources = [aws_kms_key.encrypt_storage.arn]
  }
  statement {
    sid    = "Allow S3 to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = [aws_kms_key.encrypt_storage.arn]
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy
resource "aws_kms_key_policy" "encrypt_storage" {
  key_id = aws_kms_key.encrypt_storage.id
  policy = data.aws_iam_policy_document.encrypt_storage_policy.json
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lambda" {
  name        = "${var.name}-lambda-sg"
  description = "Security group for Lambda in ${var.name}"
  vpc_id      = module.vpc.vpc.id
  tags = {
    "Name" = "${var.name}-lambda-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_vpc_endpoint_lambda" {
  description              = "allow traffic from vpc-endpoint to reach lambda"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.endpoint_sg.id
  security_group_id        = aws_security_group.lambda.id
}
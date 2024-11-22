#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint_access"
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-endpoint-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_vpc_endpoint" {
  description       = "Enable access for the endpoints."
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.endpoint_sg.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.db : subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.name}-secrets-manager"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.db : subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.name}-logs"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids          = [for subnet in aws_subnet.db : subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.name}-ssm"
  }
}
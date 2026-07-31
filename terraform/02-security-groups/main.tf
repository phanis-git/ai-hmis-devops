resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-${each.key}"
  for_each = toset(var.sg_names)
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = merge(
     local.common_tags,
        {
            Name = "${local.name_prefix}-${each.key}" #ai-hmis-dev-frontend
        }
  )
  # Egress is outgoing traffic which is same for all services
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

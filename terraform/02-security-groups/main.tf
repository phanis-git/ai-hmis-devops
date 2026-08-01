resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-${each.key}"
  for_each = toset(var.sg_names)
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
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

# SSM Parameters to share SG IDs with the security-group-rules folder
resource "aws_ssm_parameter" "sg_ids" {
  for_each = aws_security_group.main
  name     = "${var.project_name}-${var.env}-${each.key}"
  type     = "String"
  value    = each.value.id
  tags     = local.common_tags
}

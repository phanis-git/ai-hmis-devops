output "security_group_ids" {
  value = { for k, v in aws_security_group.main : k => v.id }
}

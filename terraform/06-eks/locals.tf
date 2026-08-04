locals {
  common_tags = {
   project_name = var.project_name
   owner        = "phanikumar"
   env = var.environment
  }
  name_prefix = "${var.project_name}-${var.environment}"
}

locals {
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}
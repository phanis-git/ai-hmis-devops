locals {
  common_tags = {
   project_name = var.project_name
   owner        = "phanikumar"
   env = var.env
  }
  name_prefix = "${var.project_name}-${var.env}"
}
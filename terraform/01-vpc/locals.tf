  
locals {
 common_tags = {
   project_name = var.project_name
   owner        = "phanikumar"
   env = var.env
 }
#  name_prifix = "ai-hmis"
  name_prefix = "${var.project_name}-${var.env}"
 availability_zone = slice(data.aws_availability_zones.available.names,0,2)
}
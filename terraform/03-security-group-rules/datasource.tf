data "aws_ssm_parameter" "frontend" {
  name = "${var.project_name}-${var.env}-frontend"
}
# ai-hmis-dev-frontend
data "aws_ssm_parameter" "backend" {
  name = "${var.project_name}-${var.env}-backend"
}
data "aws_ssm_parameter" "database" {
  name = "${var.project_name}-${var.env}-database"
}
data "aws_ssm_parameter" "vpc_cidr" {
  name = "${var.project_name}-${var.env}-vpc-cidr"
}

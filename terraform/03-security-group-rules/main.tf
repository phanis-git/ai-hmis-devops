# Rule 1
# Internet → Frontend (HTTP)
resource "aws_security_group_rule" "internet_to_frontend_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_ssm_parameter.frontend.value
  description = "Allowing internet to frontend via http"
}
# Rule 2
# Internet → Frontend (HTTPS)
resource "aws_security_group_rule" "internet_to_frontend_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_ssm_parameter.frontend.value
  description = "Allowing internet to frontend via https"
}

# Rule 3
# Frontend → Backend
resource "aws_security_group_rule" "frontend_to_backend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = data.aws_ssm_parameter.frontend.value
  security_group_id = data.aws_ssm_parameter.backend.value
  description = "Allowing traffic from frontend to backend"
}

# Rule 4
# Backend → Database
resource "aws_security_group_rule" "backend_to_database" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = data.aws_ssm_parameter.backend.value
  security_group_id = data.aws_ssm_parameter.database.value
  description = "Allowing traffic from backend to database"
}

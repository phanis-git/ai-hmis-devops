locals {

#   cluster_name = data.aws_ssm_parameter.cluster_name.value
cluster_name = "${var.project_name}-${var.environment}-eks-cluster"
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
  }
}
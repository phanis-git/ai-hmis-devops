# data "aws_ssm_parameter" "cluster_name" {
#   name = "${var.project_name}-${var.environment}-eks-cluster-name"
# }
# data "aws_eks_cluster" "eks" {
#   name = local.cluster_name
# }

# data "aws_caller_identity" "current" {}

# data "aws_iam_openid_connect_provider" "oidc" {
#   url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }
data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
# data "aws_iam_openid_connect_provider" "oidc" {
#   url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }
data "aws_vpc" "main" {
  tags = {
    Name = local.name_prefix
  }
}
# ============================================================
# EXISTING AWS LOAD BALANCER CONTROLLER IAM ROLE
# ============================================================
# data "aws_iam_role" "aws_load_balancer_controller_role_arn" {

#   name = "${var.project_name}-${var.environment}-aws-load-balancer-controller-role"
# }
# --------------------------------------------------
# Existing EKS Cluster
# --------------------------------------------------

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}
# --------------------------------------------------
# EKS Authentication
# --------------------------------------------------

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}
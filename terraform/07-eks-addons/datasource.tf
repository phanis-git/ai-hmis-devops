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
# data "aws_iam_role" "eks_cluster_role" {
#   name = "eks_cluster_role"
# }

data "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"  //ai-hmis-dev-eks-cluster-role
}

data "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-${var.environment}-eks-node-role"   //ai-hmis-dev-eks-node-role
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "${var.project_name}-${var.environment}-private-subnet-ids"
}

# ==========
# EKS CLUSTER CREATION 
# ===========
resource "aws_eks_cluster" "eks_cluster" {
  name  = "${var.project_name}-${var.environment}-eks-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = var.eks_cluster_role_arn
  version  = "1.35"

  vpc_config {
    subnet_ids = [
      aws_subnet.az1.id,
      aws_subnet.az2.id,
      aws_subnet.az3.id,
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

# Need to check eks and we should not push terraform init .. bundles use gitignore
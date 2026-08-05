# ==========
# EKS CLUSTER CREATION 
# ===========
resource "aws_eks_cluster" "eks_cluster" {
  name  = "${var.project_name}-${var.environment}-eks-cluster"
  access_config {
    authentication_mode = "API"
  }
  role_arn = data.aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = local.private_subnet_ids
  }
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  # depends_on = [
  #   aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  # ]
}

# Need to check eks and we should not push terraform init .. bundles use gitignore

resource "aws_eks_node_group" "aws_eks_managed_node_group" {

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"

  node_role_arn = data.aws_iam_role.eks_node_role.arn

  subnet_ids = local.private_subnet_ids

  ami_type = "AL2023_x86_64_STANDARD"

  capacity_type = "SPOT"

  instance_types = [
    "t3.medium"
  ]
  disk_size = 20
  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }
  update_config {
    max_unavailable = 1
  }
  labels = {
    environment = var.environment
    project     = var.project_name
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-node-group"
    }
  )
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_access_entry" "github_actions_user" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::100024219463:user/techphanikumar"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.github_actions_user.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
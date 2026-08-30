# =========
# FOR EKS CLUSTER ROLE
# =========== 
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"   //ai-hmis-dev-eks-cluster-role

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )
}
# =========
# FOR EKS CLUSTER ROLE POLICY
# =========== 
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role       = aws_iam_role.eks_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

# ========
# 2. Node Group IAM Role
# ========

resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-${var.environment}-eks-node-role"  //ai-hmis-dev-eks-node-role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-node-role"
    }
  )
}

# ========
# 2. Node Group IAM Role POLICY
# ========
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}



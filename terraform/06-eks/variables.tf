variable "environment" {
  type = string
  default = "dev"
}
variable "project_name" {
  default = "ai-hmis"
}
variable "eks_cluster_role_arn" {
  default = data.aws_iam_role.eks_cluster_role.arn
}
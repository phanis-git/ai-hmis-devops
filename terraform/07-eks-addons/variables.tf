
variable "project_name" {
  default = "ai-hmis"
}

variable "environment" {
  default = "dev"
}

variable "aws_region" {

  description = "AWS region"
  default = "us-east-1"
  type = string
}


variable "eks_cluster_name" {

  description = "EKS cluster name"
  default = "ai-hmis-dev-eks-cluster"
  type = string
}


# variable "vpc_id" {
#   description = "VPC ID"
#   default = data.aws_vpc.main.id
#   type = string
# }


# variable "aws_load_balancer_controller_role_arn" {

#   description = "IAM Role ARN for AWS Load Balancer Controller"

#   type = string
# }
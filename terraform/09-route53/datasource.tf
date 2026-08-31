# data "aws_lb" "ai_hmis_alb" {
#   name = "your-alb-name"
# }
data "aws_lbs" "ai_hmis" {
  tags = {
    "elbv2.k8s.aws/cluster" = "${var.project_name}-${var.env}-eks-cluster"
  }
}
data "aws_lb" "ai_hmis_alb" {
  arn = one(data.aws_lbs.ai_hmis.arns)
}
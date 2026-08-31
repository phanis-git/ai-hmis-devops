data "aws_acm_certificate" "example" {
  domain   = "devops-phani.fun"
  statuses = ["ISSUED"]
}
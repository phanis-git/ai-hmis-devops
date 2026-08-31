# output "ingress_class_name" {
#   description = "The Ingress Class Name used by the ALB Ingress"
# #   value       = resource.kubernetes_manifest.ingress.object.spec.ingressClassName
#   value       = kubernetes_ingress_v1.ingress.spec[0].ingress_class_name
# }

# output "ingress_class_name" {
#   description = "The Ingress Class Name used by the ALB Ingress"
#   value       = "alb"
# }
output "acm_certificate_arn" {
  description = "ACM certificate ARN used by the Ingress"
  value       = data.aws_acm_certificate.example.arn
}

output "ingress_class_name" {
  description = "The Ingress Class Name used by the ALB Ingress"
  value       = kubernetes_manifest.ingress.manifest.spec.ingressClassName
}
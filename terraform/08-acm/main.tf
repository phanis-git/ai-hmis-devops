
  resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
     subject_alternative_names = [
    "*.${var.domain_name}"
    ]
    tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-acm"
        }
    )

  lifecycle {
    create_before_destroy = true
  }
}
# Create DNS validation records in Route 53
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id

  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

# Wait until ACM certificate is validated
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = [
    for record in aws_route53_record.acm_validation :
    record.fqdn
  ]
}
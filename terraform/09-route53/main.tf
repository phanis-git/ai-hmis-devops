resource "aws_route53_record" "www" {
    zone_id = var.hosted_zone_id
    name    = var.domain_name
    type    = "A"
    # ttl     = 5
    alias {
    # name                   = "k8s-aihmisna-aihmisin-7eed9e0bf9-1896080296.us-east-1.elb.amazonaws.com"
    name                   = data.aws_lb.ai_hmis_alb.dns_name
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }
}
        

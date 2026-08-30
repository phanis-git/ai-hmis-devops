resource "aws_route53_record" "www" {
    zone_id = var.hosted_zone_id
    name    = var.domain_name
    type    = "A"
    # ttl     = 5
    alias {
    name                   = "k8s-aihmisna-aihmisin-7eed9e0bf9-1896080296.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }
}
        
#         ns-1085.awsdns-07.org

# ns-127.awsdns-15.com

# ns-1784.awsdns-31.co.uk

# ns-619.awsdns-13.net
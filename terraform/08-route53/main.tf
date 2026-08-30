resource "aws_route53_record" "main" {
    zone_id = var.hosted_zone_id
    name    = var.domain_name
    type    = "A"
    ttl     = 5
    # records = [aws_eip.lb.public_ip]
#      records = [
#     aws_route53_zone.example.name_servers[0],
#     aws_route53_zone.example.name_servers[1],
#     aws_route53_zone.example.name_servers[2],
#     aws_route53_zone.example.name_servers[3],
#   ]
}
        
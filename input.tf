data "aws_route53_zone" "main" {
  count = length(var.postgresql_domain_names) > 0 ? 1 : 0
  name  = var.postgresql_domain_zone_name
}

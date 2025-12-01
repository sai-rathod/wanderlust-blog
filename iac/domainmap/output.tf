output "name-servers" {
  value = aws_route53_zone.my-zone.name_servers
}
output "domain-zone-id" {
  value = aws_route53_zone.my-zone.zone_id
}
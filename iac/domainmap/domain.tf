resource "aws_route53_zone" "my-zone" {
  name = var.domain_name
}

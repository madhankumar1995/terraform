resource "aws_route53_zone" "doohp_route53_zone" {
  name     = var.aws_route53
  comment  = "${var.aws_route53} public zone"
  provider = aws
}

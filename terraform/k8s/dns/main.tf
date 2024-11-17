terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}

data "aws_route53_zone" "billv_ca" {
  name         = "billv.ca."
}

resource "aws_route53_record" "star_billv_ca" {
  zone_id = data.aws_route53_zone.billv_ca.id
  name = "*.billv.ca"
  type = "CNAME"
  ttl = 60
  records = ["home.vandenberk.me"]
}
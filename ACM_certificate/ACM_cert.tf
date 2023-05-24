#A_record
resource "aws_route53_record" "dns_validation" {
  zone_id = "Z08290211FOHNWIHSYSPP"
  name    = "satya.aws.crlabs.cloud"
  type    = "A"
  ttl     = 300
  records = ["192.168.0.0"]
}

#ACM_certificate
resource "aws_acm_certificate" "aws_cert" {
  domain_name       = "satya.aws.crlabs.cloud"
  validation_method = "DNS"
}

data "aws_route53_zone" "aws_zone" {
  name         = "satya.aws.crlabs.cloud"
  private_zone = false
}

resource "aws_route53_record" "aws_record" {
  for_each = {
    for dvo in aws_acm_certificate.aws_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.aws_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validaition" {
  certificate_arn         = aws_acm_certificate.aws_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.aws_record : record.fqdn]
}

#alb_security_group
resource "aws_security_group" "alb_secg" {
  name        = "alb_sg"
  description = "Security group for alb"
  vpc_id      = module.mig-vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0"]
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_tls"
  }
}

#PGP_security_group
resource "aws_security_group" "pgp_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

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
    Name = "alb_secg"
  }
}

#PGadmin_security_group
resource "aws_security_group" "pga_sg" {
  name        = "pga_sg"
  description = "Allow inbound traffic"
  vpc_id      = module.mig-vpc.vpc_id

  ingress {
    description      = "https connection from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.main.cidr_block]
    security_groups = [data.aws_security_group.alb_secg.id]
  }

  # ingress {
  #   description      = "ssh into pgadmin"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["10.0.0.0/16"]
  #}

  ingress {
    description      = "http into pgadmin"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [data.aws_security_group.alb_secg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pga_sg"
  }
}

#Applicaiton_load_balancer
resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_secg.id]
  subnets            = module.mig-vpc.public_subnets

  enable_deletion_protection = true

  tags = {
    Project = "mig_alb"
  }
}

#http and https listener
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-1:309162523117:certificate/e78edeae-9c3c-44e4-a443-5f507cb965e7"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_pgadmin.arn
  }
 }

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-1:309162523117:certificate/e78edeae-9c3c-44e4-a443-5f507cb965e7"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_pgadmin.arn
  }
 }

#redirection from port 80 to 443
resource "aws_lb_listener" "alb_redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#target group for pgadmin
resource "aws_lb_target_group" "target_pgadmin" {
  name     = "target_grp_pgadmin"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.mig-vpc.vpc_id
}

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }




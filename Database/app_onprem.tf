#ONPREM_APP_SERVER
resource "aws_instance" "onprem_app_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "migration_key"
  user_data = templatefile("${path.module}/app_user_data.sh.tpl", {
    db_private_ip       = aws_instance.onprem_db_instance.private_ip
    mysql_root_password = local.mysql_password
  })
  network_interface {
    network_interface_id = aws_network_interface.app_onprem_ni.id
    device_index         = 0
  }
  tags = {
    Name = "onprem_app_instance"
  }
}

resource "aws_network_interface" "app_onprem_ni" {
  subnet_id       = data.aws_subnet.onprem_data_pub.id
  security_groups = [aws_security_group.onprem_app_sg.id]

  tags = {
    Name = "onprem_app_ni"
  }
}

resource "aws_security_group" "onprem_app_sg" {
  name        = "onprem_app_sg"
  description = "security group of onprem db"
  vpc_id      = data.aws_vpc.onprem_app.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onprem_app_sg"
  }
}
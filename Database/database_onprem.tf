#ON-PREMISES-DB-SERVER
resource "aws_instance" "onprem_db_instance" {
  ami           = data.aws_ami.ubuntu
  instance_type = "t2.medium"
  subnet_id     = data.aws_subnet.onprem_data
  key_name = "migration_key"
  vpc_security_group_ids = [aws_security_group.onprem_db_sg.id]
  user_data = templatefile("${path.module}/db_user_data.sh.tpl" , {
  onpremapp_private_ip = aws_network_interface.app_onprem_ni.private_ip,
  mysql_root_password = local.mysql_password 
  })
tags = {
    Name = "onprem_db_instance"
  }
}


resource "aws_security_group" "onprem_db_sg" {
  name        = "onprem_db_sg"
  description = "security group of onprem db"
  vpc_id      = data.aws_vpc.onprem_app.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_security_group.onprem_app_sg.id]
    }

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [aws_security_group.onprem_app_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql_sg"
  }
}


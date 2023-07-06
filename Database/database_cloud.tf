resource "aws_db_instance" "cloud_db" {
  allocated_storage    = 10
  auto_minor_version_upgrade = true
  availability_zone = local.availability_zone
  backup_retention_period = 7
  backup_window        =  "09:00-09:30" 
  db_name              = "mydb"
  db_subnet_group_name = local.db_subnet_group
  engine               = "postgres"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.username
  password             = var.password
  storage_encrypted    = true
  storage_type         = "gp3"
  storage_throughput   = 125
  iops                 = 3000
  parameter_group_name = "default.mysql5.7"
  maintenance_window   = "Sun1000-Sun1030" 
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.cloud_db_sg.id]
}

resource "aws_security_group" "cloud_db_sg" {
  name        = "cloud_db_sg"
  description = "Allow connections into the database"
  vpc_id      = aws_vpc.post_db.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
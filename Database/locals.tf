locals {
  mysql_password = "pass3456"
  db_subnet_group = "cloud_vpc" 
  availability_zone = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
}
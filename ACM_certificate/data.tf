data "aws_vpc" "migra_project" {
  filter {
    name   = "tag:Name"
    values = ["cloud_vpc"]
  }
}

data "aws_subnet" "mig_pub_sub_1" {
  filter {
    name   = "tag:Name"
    values = ["cloud_vpc-public-eu-west-1a"]
  }
}

data "aws_subnet" "mig_pub_sub_2" {
  filter {
    name   = "tag:Name"
    values = ["cloud_vpc-public-eu-west-1b"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
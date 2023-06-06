data "aws_subnet" "onprem_data" {
    filter {
    name   = "tag:Name"
    values = ["on_prem_vpc-private-eu-west-1a"]
}
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "onprem_data_pub" {
    filter {
    name   = "tag:Name"
    values = ["on_prem_vpc-public-eu-west-1a"]
}
}

data "aws_vpc" "onprem_app" {
  filter {
    name   = "tag:Name"
    values = ["on_prem_vpc"]
  }
}

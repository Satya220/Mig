locals {
availability_zones = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
private_subnet_cidr = cidrsubnet(var.vpc_cidr, 1, 1)
public_subnet_cidr  = cidrsubnet(var.vpc_cidr, 1, 0)
database_subnet_cidr = cidrsubnet(var.vpc_cidr, 2, 1)


azs_on_prem =  slice(data.aws_availability_zones.available.names, 0, var.number_of_azs_on_perm)
private_subnet_on_prem_cidr = cidrsubnet(var.on_prem_vpc_cidr, 1, 1)
public_subnet_on_prem_cidr  = cidrsubnet(var.on_prem_vpc_cidr, 1, 0)
database_subnet_on_prem_cidr = cidrsubnet(var.on_prem_vpc_cidr, 2, 1)
}
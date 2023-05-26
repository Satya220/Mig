module "mig-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  private_subnets  = [for i, v in local.availability_zones : cidrsubnet(local.private_subnet_cidr, 2, i)]
  public_subnets  = [for i, v in local.availability_zones : cidrsubnet(local.public_subnet_cidr, 2, i)]
  
  enable_nat_gateway = true
}

module "on_prem_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.on_prem_vpc_name
  cidr = var.on_prem_vpc_cidr

  azs             = local.azs_on_prem
  private_subnets = [for i, v in local.azs_on_prem : cidrsubnet(local.private_subnet_on_prem_cidr, 2, i)]
  public_subnets  = [for i, v in local.azs_on_prem : cidrsubnet(local.public_subnet_on_prem_cidr, 2, i)]
}
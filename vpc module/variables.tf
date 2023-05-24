variable "vpc_name" {
    description = "This is the VPC name"
    type = string
}

variable "vpc_cidr" {
    description = "This is the cidr of the VPC "
}

# variable "private_subnet_cidr" {
#     description = "This is the cidr block of the private subnet "
# }

# variable "public_subnet_cidr" {
#     description = "This is the cidr block of the public subnet "
# }

# variable "database_subnet_cidr" {
#     description = "This is the cidr block of the public subnet "
# }

variable "number_of_azs" {
    description = "This is the number of availability zones "
}

variable "on_prem_vpc_cidr" {
    description = "This is the cidr of the VPC on premises"
}

# variable "private_subnet_on_prem_cidr" {
#     description = "This is the cidr block of the private subnet on premises"
# }

# variable "public_subnet_on_prem_cidr" {
#     description = "This is the cidr block of the public subnet on premises"
# }

# variable "database_subnet_on_prem_cidr" {
#     description = "This is the cidr block of the public subnet on premises "
# }

variable "number_of_azs_on_perm" {
    description = "This is the number of availability zones for on premises"
}

 variable "on_prem_vpc_name" {
    description = "This is the name on premises vpc"
}
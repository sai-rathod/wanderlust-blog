variable "vpc_cidr" {
    description = "provide vpc cidr"
    type = string
}
variable "env" {
    description = "provide env type eg:dev,staging,prod"
    type = string
    default = "dev"
}
variable "public_subnet_cidr" {
    description = "provide public_subnets cidr in list(min two)"
    type = list(string)
}
variable "private_subnet_cidr" {
    description = "provide private_subnets cidr in list(min two)"
    type = list(string)
}
variable "sg_ports" {
    description = "list of ports you want to allow"
    type = list(number)
}

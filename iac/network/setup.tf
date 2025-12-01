resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "my-vpc"
      env = var.env
    }

}
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "my-igw"
      env = var.env
    }

}
data "aws_availability_zones" "region_zones" {
  state = "available"
}
resource "aws_subnet" "public-subnet" {
    count = length(var.public_subnet_cidr)
    cidr_block = var.public_subnet_cidr[count.index]
    vpc_id = aws_vpc.my-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.region_zones.names[count.index]
    tags = {
      Name = "public-subnet"
      env = var.env
    }

}
resource "aws_subnet" "private-subnet" {
    count = length(var.private_subnet_cidr)
    cidr_block = var.private_subnet_cidr[count.index]
    vpc_id = aws_vpc.my-vpc.id
    availability_zone = data.aws_availability_zones.region_zones.names[count.index]
    tags = {
      Name = "private-subnet"
      env = var.env
    }

}
resource "aws_route_table" "pubilc-route-table" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
    tags = {
      name = "public_route_table"
      env = var.env
    }

}
resource "aws_route_table_association" "public-route" {
    count = length(var.public_subnet_cidr)
    route_table_id = aws_route_table.pubilc-route-table.id
    subnet_id = aws_subnet.public-subnet[count.index].id

}
resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-vpc.id
    dynamic "ingress" {
        for_each = var.sg_ports
        content {
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "instance-sg"
      env = var.env
    }

}

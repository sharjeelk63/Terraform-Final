# Declare the AWS resource VPC 
resource "aws_vpc" "demo-vpc" { 
    cidr_block = var.cidr_block
    instance_tenancy = "default"
}

# Create Public subnet in each AZ
resource "aws_subnet" "public_subnet" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.public_subnet_cidr_blocks[count.index] 
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true
}
# Create Private Subnet in each AZ
resource "aws_subnet" "private_subnet" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = false  
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.demo-vpc.id
}

# Create a public route table for the VPC with a default route to the Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_internet_gateway.id
  }
  tags = {
    Name = "dev-proj-1-public-rt"
  }
}

# Associate the public route table with each public subnet
resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private route table for the VPC (no default route to the Internet Gateway)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.demo-vpc.id  
}

# Associate the private route table with each private subnet
resource "aws_route_table_association" "private_route_association" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}



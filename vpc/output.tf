output "public_ip" {
    description = "This is the public IP for the assigned to public subnet"
    value = aws_internet_gateway.public_internet_gateway.id
}

output "vpc-sg" {
    description = "This is the default sg that is created"
    value = aws_vpc.demo-vpc.default_security_group_id  
}
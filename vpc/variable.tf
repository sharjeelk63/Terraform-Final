variable "cidr_block" {
    description = "CIDR Block for the VPC"
    type = string
    default = "192.168.0.0/16"  
}
variable "public_subnet_cidr_blocks" {
    description = "CIDR Blocks for public subnet"
    type = list(string)
    default = [ "192.168.1.0/24" , "192.168.2.0/24" ]  
}
variable "private_subnet_cidr_blocks" {
    description = "CIDR Blocks for private subnet"
    type = list(string)
    default = [ "192.168.3.0/24" , "192.168.4.0/24" ]
  
}
variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
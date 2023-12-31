output "Instance_private_IP" {
  description = "This is the Pulic IP for the instance "
  value = aws_instance.demo-instance.private_ip
}

output "Instance_public_IP" {
  description = "This is the Pulic IP for the instance "
  value = aws_instance.demo-instance.public_ip
}
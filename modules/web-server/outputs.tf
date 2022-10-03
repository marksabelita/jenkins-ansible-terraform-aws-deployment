output "ec2-public-ip" {
  value = aws_instance.my-app-server.public_ip
}
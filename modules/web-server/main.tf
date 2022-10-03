data "aws_ami" "lastest-amazon-linux-image" {
  most_recent = true
  owners = [var.instance_owner]

  filter {
    name = "name"
    values = [var.instance_name]
  }

  filter {
    name = "virtualization-type"
    values = [var.virtualization_type]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key-pair"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "my-app-server" {
  ami = data.aws_ami.lastest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnets[0]
  vpc_security_group_ids = [var.security_group_id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    Terraform = "true"
    Name = "${var.env_prefix}-ec2-server"
    Project = var.project
  }
}
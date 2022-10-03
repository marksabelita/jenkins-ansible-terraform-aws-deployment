terraform {
	required_version = ">= 0.12"
	backend "s3" {
		bucket = "mark-terraform-jenkins-state"
		key="jenkins/state.tfstate"
		region="eu-west-1"
	}
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${var.env_prefix}-VPC"
  cidr = "10.0.0.0/16"

  azs             = [var.availability_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env_prefix}-public-subnet"
  }

  tags = {
    Terraform = "true"
    Project= var.project
    Environment = var.env_prefix
    Name = "${var.env_prefix}-vpc"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.env_prefix}-security-group"
  description = "Security group for ${var.env_prefix}-web-server with HTTP ports open."
  vpc_id      = module.vpc.vpc_id
  
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "${var.env_prefix}-web-server-port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "${var.env_prefix}-ssh-port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "web-server" {
  source = "./modules/web-server"
  env_prefix = var.env_prefix
  instance_owner = var.instance_owner
  instance_type = var.instance_type
  public_key_location = var.public_key_location
  instance_name = var.instance_name
  virtualization_type = var.virtualization_type
  subnets = module.vpc.public_subnets
  availability_zone = var.availability_zone
  security_group_id = module.web_server_sg.security_group_id
  project = var.project
}

resource "null_resource" "execute-ansible" {
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = module.web-server.ec2-public-ip
      user = "centos"
      private_key = "${file(var.private_key_location)}"
    }

    inline = ["echo 'connected!'"]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/aws_ec2.yml ansible/playbook/jenkins-server.yml"
  }
}
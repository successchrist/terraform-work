provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "&{var.env_prefix}-vpc"
  }
}
resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "&{var.env_prefix}-subnet_1"
  }
}
resource "aws_route_table" "myapp_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name : "&{var.env_prefix}-rtb"
  }

}
resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "&{var.env_prefix}-igw"
  }
}
resource "aws_route_table_association" "association_rtb_subnet" {
  subnet_id      = aws_subnet.myapp_subnet_1.id
  route_table_id = aws_route_table.myapp_route_table.id

}
/*
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags ={
    Name: "&{var.env_prefix}-default_route_table"
  }
}*/
resource "aws_security_group" "myapp_sg" {
    name = "myapp_sg"
  vpc_id = aws_vpc.myapp_vpc.id

ingress {
  description = "TLS from VPC"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  // cidr_blocks      = [var.my_ip] defining an ip(whatismyip.org)
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"          //(for any protocol)
  cidr_blocks = ["0.0.0.0/0"] // (for any ip address)
}
  tags = {
    Name = "&{var.env_prefix}-sg"
  }
}
data "aws_ami" "latest_amazon_linux_image" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp_server" {
   ami           = data.aws_ami.latest_amazon_linux_image.id
 instance_type = var.instance_type
  
  /* want my instance to be created in the subnet i created 
  and assigned the security group of this vpc not in the default, 
  have to specify the values*/
  subnet_id = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true

/*resource "aws_key_pair" "ssh_key" {
  key_name   = "myapp_key"
  public_key = var.my_public_key
}*/
     user_data = <<EOF
             #!/bin/bash
             sudo yum update -y && sudo yum install docker -y
             systemctl start docker
             add ec2_user to docker group
             sudo usermod-aG docker ec2_user
             docker run -p 8080:80 nginx

        EOF
     //user_data = file("entry_script.sh")

      tags = {
       Name = "&{var.env_prefix}-myapp_server"
     }
}


























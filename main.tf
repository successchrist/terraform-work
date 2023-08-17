provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "dev-vpc" {
   cidr_block = "10.0.0.0/16"
   
   
  tags = {
    Name = "dev-vpc"
  }


}
resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "dev-subnet-1"
  }
}

data "aws_vpc" "dev-vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = data.aws_vpc.dev-vpc.id
  availability_zone = "us-east-1a"
   cidr_block = "10.0.2.0/24"

    tags = {
    Name = "dev-subnet-2"
  }
}
output "dev_vpc_id" {
  value = aws_vpc.dev-vpc.id
}
output "dev_subnet_id" {
  value = aws_subnet.dev-subnet-1.id
}





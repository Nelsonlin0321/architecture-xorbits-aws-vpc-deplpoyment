terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.18"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

// Create VPC
resource "aws_vpc" "xorbits-vpc" {
  cidr_block                       = var.vpc-cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "xorbits-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.xorbits-vpc.id
  cidr_block              = var.public-subnet-cidr
  availability_zone       = var.public-subnet-az
  map_public_ip_on_launch = true
  tags = {
    Name = "xorbits public subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.xorbits-vpc.id
  cidr_block        = var.private-subnet-cidr
  availability_zone = var.private-subnet-az
  tags = {
    Name = "xorbits private subnet"
  }
}

resource "aws_security_group" "xorbits-vpc-ssh-sg" {
  name = "xorbits-vpc-ssh"

  vpc_id = aws_vpc.xorbits-vpc.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "xorbits-vpc-ssh"
  }
}

resource "aws_internet_gateway" "xorbits-vpc-igw" {
  vpc_id = aws_vpc.xorbits-vpc.id
  tags = {
    Name = "xorbits-vpc-igw"
  }
}

resource "aws_route_table" "xorbits-vpc-public-rt" {
  vpc_id = aws_vpc.xorbits-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xorbits-vpc-igw.id
  }
  tags = {
    Name = "xorbits-vpc-public-rt"
  }
}

// associate public subnet with public route table 
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.xorbits-vpc-public-rt.id
}


resource "aws_instance" "public-instance" {
  ami                         = var.machine_image
  instance_type               = var.instance-type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.xorbits-vpc-ssh-sg.id]
  user_data                   = <<EOF
  #!/bin/bash
  sudo apt update
  sudo apt install python3
  EOF
}


provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "dpp-public-subnet-01" {
  vpc_id                  = aws_vpc.dpp-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "dpp-public-subnet-01"
  }
}

# Public Subnet 2
resource "aws_subnet" "dpp-public-subnet-02" {
  vpc_id                  = aws_vpc.dpp-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "dpp-public-subnet-02"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

# Route Table
resource "aws_route_table" "dpp-rut" {
  vpc_id = aws_vpc.dpp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }

  tags = {
    Name = "dpp-public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
  subnet_id      = aws_subnet.dpp-public-subnet-01.id
  route_table_id = aws_route_table.dpp-rut.id
}

resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
  subnet_id      = aws_subnet.dpp-public-subnet-02.id
  route_table_id = aws_route_table.dpp-rut.id
}

# Security Group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.dpp-vpc.id

  ingress {
    description = "ssh-access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

# Key Pair (new step)
resource "aws_key_pair" "project_key" {
  key_name   = "project-key"
  public_key = file("C:/Users/laxmi/.ssh/id_rsa.pub") # <-- Make sure you have this cd
}

# EC2 Instances (2 using for_each)
resource "aws_instance" "demo-ec2" {
  for_each               = toset(["jenkins-master", "Ansible","jenkis-slave-node"])
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.project_key.key_name
  subnet_id              = aws_subnet.dpp-public-subnet-01.id
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  

  tags = {
    Name = each.key
  }
}


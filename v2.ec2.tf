provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-ec2" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  key_name      = "project-key"

  vpc_security_group_ids = [aws_security_group.demo-sg.id]

  tags = {
    Name = "demo-ec2"
  }
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow SSH inbound traffic and all outbound traffic"

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
    Name = "ssh-prot"
  }
}

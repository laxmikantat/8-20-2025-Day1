provider  "aws" {
    region ="us-east-1"
}

resource "aws_instance" "demo-server" {
    ami= "ami-00ca32bbc84273381"
    instance_type= "t2.micro"
    key_name = "project-key"
}
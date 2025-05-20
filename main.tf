provider "aws" {
  region = "us-west-1"  # Northern California
}

resource "aws_vpc" "splunk_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "splunk_igw" {
  vpc_id = aws_vpc.splunk_vpc.id
}

resource "aws_subnet" "splunk_subnet" {
  vpc_id     = aws_vpc.splunk_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "splunk_route_table" {
  vpc_id = aws_vpc.splunk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.splunk_igw.id
  }
}

resource "aws_route_table_association" "splunk_route_table_association" {
  subnet_id      = aws_subnet.splunk_subnet.id
  route_table_id = aws_route_table.splunk_route_table.id
}

resource "aws_security_group" "splunk_sg" {
  name_prefix = "splunk-sg-"
  vpc_id      = aws_vpc.splunk_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["97.170.215.238/32"]  # твой IP
  }

  ingress {
    description = "Splunk Web UI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["97.170.215.238/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # чтобы наружу уходить
  }
}

resource "aws_instance" "splunk_server" {
  ami                         = "ami-05e1c8b4e753b29d3"  # твой найденный AMI
  instance_type               = "t3.large"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.splunk_subnet.id
  vpc_security_group_ids      = [aws_security_group.splunk_sg.id]
  key_name                    = "splunk-connect"  # твой .pem ключ

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y wget tar

              wget -O /tmp/splunk-9.2.1-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.2.1/linux/splunk-9.2.1-35194fdd4d15-Linux-x86_64.tgz"
              mkdir -p /opt
              tar -xvf /tmp/splunk-9.2.1-Linux-x86_64.tgz -C /opt
              /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
              /opt/splunk/bin/splunk enable boot-start
              EOF

  tags = {
    Name = "SplunkServer"
  }
}

output "splunk_web_url" {
  description = "URL to access Splunk Web UI"
  value       = "http://${aws_instance.splunk_server.public_ip}:8000"
} 

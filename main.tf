terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

# create a cloud watch

resource "aws_cloudwatch_metric_alarm" "my_cloudwatch" {
     alarm_name                = "cpu-utilization"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "60"
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 cpu utilization"
     #insufficient_data_actions = []

     dimensions = {
       
         InstanceId = aws_instance.my_server.id     
        }
}

# vpc creation using terraform

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my vpc"
  }
}

# create the Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2c"
tags = {
   Name = "my subnet"
  }
}

# store variable

output "endpoit_data" {
     value = aws_db_instance.my_db.address
}

# subnet2

resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
tags = {
   Name = "my subnet2"
  }
}

# subnet for db

resource "aws_db_subnet_group" "my_db_subnet" {
  subnet_ids = [aws_subnet.my_subnet.id, aws_subnet.my_subnet1.id ]

  tags = {
    Name = "My DB subnet group"
  }
}

# db creation

resource "aws_db_instance" "my_db" {
  identifier           = "sagdb"
  allocated_storage    = 10
  engine               = "mysql"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet.id
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "my_db"
  username             = "admin"
  password             = "admingokul"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

#securitygroup using Terraform

resource "aws_security_group" "my_secure" {
  name        = "security group using Terraform"
  description = "security group using Terraform"
  vpc_id      = aws_vpc.my_vpc.id
  
  ingress {
    description      = "HTTPS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "secure"
  }
}

#create vpc access control 

resource "aws_network_acl" "my_network" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9100
    to_port    = 9100
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9090
    to_port    = 9090
  }

  egress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3000
    to_port    = 3000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9100
    to_port    = 9100
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 9090
    to_port    = 9090
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3000
    to_port    = 3000
  }


  tags = {
    Name = "my network"
  }
}

# internet gatway

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my gateway"
  }
}

#public ip

resource "aws_eip" "my_ip" {
  instance = aws_instance.my_server.id
  vpc      = true
}

# create route table

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = {
    Name = "my route table"
  }
}

#create route

resource "aws_route" "my_route" {
  route_table_id            = aws_route_table.my_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.my_gateway.id
}

#route table association

resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

#creating ec2

resource "aws_instance" "my_server" {
  ami             = "ami-0d70546e43a941d70"
  instance_type   = "t2.micro"
#  security_groups = [aws_security_group.my_secure.id]

subnet_id = aws_subnet.my_subnet.id
vpc_security_group_ids =  [aws_security_group.my_secure.id]
  provisioner "local-exec" {
    command = "echo $endpoit_data > /root/sai/html/summa.txt"
  }
  tags = {
    Name = "MyEc2Linux"
  }
  user_data = file("web.sh")
}

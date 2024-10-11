terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example VPC"
  }
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "public-subnet-${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "private-subnet-${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-"

  vpc_id = aws_vpc.main.id

  # Add any additional ingress/egress rules as needed
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "our_ec2_instance" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  count = length(var.private_subnet_cidrs)
  subnet_id     = element(aws_subnet.private_subnets[*].id, count.index)
}


resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "private subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage = 10
  engine = "mysql"
  instance_class = "db.t3.micro"
  username = "ninon"
  password = "bigsecret"
  skip_final_snapshot = true

vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}

resource "aws_iam_role" "example_role" {
  name = "example_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "example-storage-s3" {
   bucket = "example-storage-s3"
   policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:HeadObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::example-storage-s3",
                "arn:aws:s3:::example-storage-s3/*"
            ],
            "Effect": "Allow"
        }
    ]
}
   )
}

resource "aws_s3_bucket_policy" "example-backup-s3" {
   bucket = "example-backup-s3"
   policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:HeadObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::example-backup-s3",
                "arn:aws:s3:::example-backup-s3/*"
            ],
            "Effect": "Allow"
        }
    ]
}
   )
}


data "aws_caller_identity" "current" {}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = local.region
  default_tags {
    tags = {
      deploy = "terraform"
      environment= local.environment
    }
  }
}

locals {
  region = "eu-west-2"
  environment = "staging"
}


resource "aws_vpc" "vpc_skillorg" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    owner       = "alex"
    project = "skillorg"
  }
}

resource "aws_subnet" "snet_public_1" {
  vpc_id     = aws_vpc.vpc_skillorg.id
  availability_zone = "${local.region}a"

  cidr_block = "10.1.1.0/24"
  depends_on = [
    aws_vpc.vpc_skillorg
  ]

  tags = {
    owner = "alex"
    project= "skillorg"
  }
}


resource "aws_subnet" "snet_private_1" {
  vpc_id     = aws_vpc.vpc_skillorg.id
  availability_zone = "${local.region}a"
  cidr_block = "10.1.101.0/24"
  depends_on = [
    aws_vpc.vpc_skillorg
  ]
  tags = {
    owner = "alex"
    project= "skillorg"
  }
}

resource "aws_subnet" "snet_private_2" {
  vpc_id     = aws_vpc.vpc_skillorg.id
  availability_zone = "${local.region}b"
  cidr_block = "10.1.102.0/24"
  depends_on = [
    aws_vpc.vpc_skillorg
  ]
  tags = {
    owner = "alex"
    project= "skillorg"
  }
}

resource "aws_internet_gateway" "igw_skillorg" {
  vpc_id = aws_vpc.vpc_skillorg.id
  depends_on = [
      aws_vpc.vpc_skillorg
    ]
  tags = {
    owner = "alex"
    project= "skillorg"
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "skillorg_subnet_group_rds"
  depends_on = [
    aws_subnet.snet_private_1,
    aws_subnet.snet_private_2
  ]
  subnet_ids = [aws_subnet.snet_private_1.id, aws_subnet.snet_private_2.id]

  tags = {
      owner = "alex"
      project= "skillorg"
  }
}

resource "aws_security_group" "allow_postgres_to_home" {
  name        = "allow_postgres to home computer"
  description = "Allow Postgres inbound traffic 5432 to home computer"
  vpc_id      = aws_vpc.vpc_skillorg.id

  ingress = [
    {
      description      = "Postgres from VPC to home"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
      cidr_blocks      = ["/32"]
    },
    {
      description      = "SSH from VPC to home"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
      cidr_blocks      = ["/32"]
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    }
  ]

  tags = {
    Name = "allow_postgres"
    owner = "alex"
    project= "skillorg"
  }
}


resource "aws_security_group" "allow_all_ip_postgres" {
  name        = "allow_all_ip_postgres"
  description = "Allow All inbound traffic 5432"
  vpc_id      = aws_vpc.vpc_skillorg.id

  ingress = [
    {
      description      = "Postgres from VPC to home"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
      cidr_blocks      = ["0.0.0.0/0"]
    },
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    }
  ]

  tags = {
    Name = "allow_postgres"
    owner = "alex"
    project= "skillorg"
  }
}



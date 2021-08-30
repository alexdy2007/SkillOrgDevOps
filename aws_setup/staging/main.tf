terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56"
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

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

locals {
  region = "eu-west-2"
  environment = "staging"
}


module "skillorg_network" {
  source = "../modules/network"
}


resource "aws_rds_cluster" "postgresql_skillorg" {
  depends_on = [
      module.skillorg_network.rds_subnet_group_name,
      module.skillorg_network.aws_security_group_all_postgres_id
  ]
  cluster_identifier      = "skillorg-db-prod-1"
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  db_subnet_group_name    = module.skillorg_network.rds_subnet_group_name
  database_name           = "skillorg"
  master_username         = "postgres"
  master_password         = var.postgres_password
  backup_retention_period = 1
  skip_final_snapshot = true
  vpc_security_group_ids = [module.skillorg_network.aws_security_group_all_postgres_id]
  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 3000
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_instance" "ec2_jump_box" {
  depends_on = [
      module.skillorg_network.subnet_public_1_id,
      module.skillorg_network.aws_security_group_home_id
  ]
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name= "key-ady-local-1"
  associate_public_ip_address=true
  subnet_id=module.skillorg_network.subnet_public_1_id
  vpc_security_group_ids=[module.skillorg_network.aws_security_group_home_id]
  tags = {
    owner = "alex"
    project= "skillorg"
  }
}

resource "aws_route_table" "rtbl_public_igw" {
  depends_on = [
      module.skillorg_network.igw_id,
      module.skillorg_network.vpc_id
  ]
  vpc_id = module.skillorg_network.vpc_id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = module.skillorg_network.igw_id
    }


  tags = {
    owner = "alex"
    project= "skillorg"
  }
}
resource "aws_route_table_association" "rtbl_subnet_igw_public_assoiation" {
  depends_on = [
      aws_route_table.rtbl_public_igw
  ]
  subnet_id      = module.skillorg_network.subnet_public_1_id
  route_table_id = aws_route_table.rtbl_public_igw.id
}
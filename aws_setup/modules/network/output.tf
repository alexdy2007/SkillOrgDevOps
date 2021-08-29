output "vpc_id" {
  value = aws_vpc.vpc_skillorg.id
}

output "subnet_private_1_id" {
  value = aws_subnet.snet_private_1.id
}

output "subnet_private_2_id" {
  value = aws_subnet.snet_private_2.id
}

output "subnet_public_1_id" {
  value = aws_subnet.snet_public_1.id
}

output "rds_subnet_group_id" {
  value = aws_db_subnet_group.aurora_subnet_group.id
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.aurora_subnet_group.name
}

output "aws_security_group_home_id" {
  value = aws_security_group.allow_postgres_to_home.id
}

output "aws_security_group_all_postgres_id" {
  value = aws_security_group.allow_all_ip_postgres.id
}

output "igw_id" {
  value = aws_internet_gateway.igw_skillorg.id
}

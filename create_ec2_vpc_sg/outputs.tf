//-------------VPC & subnet-----------------------------

output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

//-------------SG-----------------------------

output "SG_id" {
  value = aws_security_group.my_sg.id
}

//-------------instance IP-----------------------------

output "my_ubuntu_server_IP" {
  value = aws_instance.my_ubuntu_server.public_ip
}

output "my_aws_server_IP" {
  value = aws_instance.my_aws_server.public_ip
}

# outputs.tf in /modules/network

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id_1" {
  value = aws_subnet.public_1.id
}

output "public_subnet_id_2" {
  value = aws_subnet.public_2.id
}



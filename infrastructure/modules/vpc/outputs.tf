output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id

  # Wait until the subnet has a route to the internet
  depends_on = [aws_route.public_internet, aws_route_table_association.public]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "public_subnet_availability_zone" {
  description = "Availability Zone of the public subnet"
  value       = aws_subnet.public.availability_zone
}

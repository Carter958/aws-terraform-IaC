# main.tf in /modules/network

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Additional VPC configuration here
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Adjust according to your region and zones
  map_public_ip_on_launch = true
  # Additional subnet configuration here
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Adjust according to your region and zones
  map_public_ip_on_launch = true
  # Additional subnet configuration here
}

# Remove these as they are duplicates of the above
# resource "aws_subnet" "public" {
#   vpc_id = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   map_public_ip_on_launch = true
# }

# resource "aws_subnet" "private" {
#   vpc_id = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
# }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

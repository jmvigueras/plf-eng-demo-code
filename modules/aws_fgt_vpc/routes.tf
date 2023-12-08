#---------------------------------------------------------------------------
# Crate Route Tables
#---------------------------------------------------------------------------
# Route public
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  tags = {
    Name = "${var.prefix}-rt-public"
  }
}
# Route private
resource "aws_route_table" "rt-bastion" {
  vpc_id = aws_vpc.vpc-sec.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-sec.id
  }
  route {
    cidr_block           = "172.16.0.0/12"
    network_interface_id = aws_network_interface.ni-private.id
  }
  route {
    cidr_block           = "192.168.0.0/16"
    network_interface_id = aws_network_interface.ni-private.id
  }
  route {
    cidr_block           = "10.0.0.0/8"
    network_interface_id = aws_network_interface.ni-private.id
  }
  tags = {
    Name = "${var.prefix}-rt-bastion"
  }
}
# Route tables associations AZ1
resource "aws_route_table_association" "ra-subnet-az1-public" {
  subnet_id      = aws_subnet.subnet-az1-public.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "ra-subnet-az1-bastion" {
  subnet_id      = aws_subnet.subnet-az1-bastion.id
  route_table_id = aws_route_table.rt-bastion.id
}
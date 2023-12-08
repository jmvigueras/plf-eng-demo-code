# ------------------------------------------------------------------
# Create all the eni interfaces FGT active
# ------------------------------------------------------------------
resource "aws_network_interface" "ni-public" {
  subnet_id         = aws_subnet.subnet-az1-public.id
  security_groups   = [aws_security_group.nsg-vpc-sec-public.id]
  private_ips       = local.fgt_ni_public_ips
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-public"
  }
}

resource "aws_network_interface" "ni-private" {
  subnet_id         = aws_subnet.subnet-az1-private.id
  security_groups   = [aws_security_group.nsg-vpc-sec-private.id]
  private_ips       = local.fgt_ni_private_ips
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-ni-private"
  }
}

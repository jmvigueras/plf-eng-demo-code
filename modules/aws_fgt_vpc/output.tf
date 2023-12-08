output "fgt_ni_ids" {
  value = {
    public  = aws_network_interface.ni-public.id
    private = aws_network_interface.ni-private.id
  }
}

output "fgt_ni_ips" {
  value = {
    public  = local.fgt_ni_public_ip
    private = local.fgt_ni_private_ip
  }
}

output "subnet_az1_cidrs" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.cidr_block
    public  = aws_subnet.subnet-az1-public.cidr_block
    private = aws_subnet.subnet-az1-private.cidr_block
    bastion = aws_subnet.subnet-az1-bastion.cidr_block
  }
}


output "subnet_az1_ids" {
  value = {
    mgmt    = aws_subnet.subnet-az1-mgmt-ha.id
    public  = aws_subnet.subnet-az1-public.id
    private = aws_subnet.subnet-az1-private.id
    bastion = aws_subnet.subnet-az1-bastion.id
  }
}

output "vpc-sec_id" {
  value = aws_vpc.vpc-sec.id
}

output "nsg_ids" {
  value = {
    mgmt      = aws_security_group.nsg-vpc-sec-mgmt.id
    ha        = aws_security_group.nsg-vpc-sec-ha.id
    private   = aws_security_group.nsg-vpc-sec-private.id
    public    = aws_security_group.nsg-vpc-sec-public.id
    bastion   = aws_security_group.nsg-vpc-sec-bastion.id
    allow_all = aws_security_group.nsg-vpc-sec-allow-all.id
  }
}
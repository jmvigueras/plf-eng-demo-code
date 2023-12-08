locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_az1_mgmt_cidr    = cidrsubnet(var.vpc-sec_cidr, 3, 0)
  subnet_az1_public_cidr  = cidrsubnet(var.vpc-sec_cidr, 3, 1)
  subnet_az1_private_cidr = cidrsubnet(var.vpc-sec_cidr, 3, 2)
  subnet_az1_tgw_cidr     = cidrsubnet(var.vpc-sec_cidr, 3, 3)
  subnet_az1_gwlb_cidr    = cidrsubnet(var.vpc-sec_cidr, 3, 4)
  subnet_az1_bastion_cidr = cidrsubnet(var.vpc-sec_cidr, 3, 5)

  # ----------------------------------------------------------------------------------
  # FGT IP (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt_ni_mgmt_ip    = cidrhost(local.subnet_az1_mgmt_cidr, 10)
  fgt_ni_public_ip  = cidrhost(local.subnet_az1_public_cidr, 10)
  fgt_ni_private_ip = cidrhost(local.subnet_az1_private_cidr, 10)

  # ----------------------------------------------------------------------------------
  # FGT IPs (NOT UPDATE)
  # ----------------------------------------------------------------------------------
  fgt_ni_mgmt_ips    = [local.fgt_ni_mgmt_ip]
  fgt_ni_public_ips  = [local.fgt_ni_public_ip]
  fgt_ni_private_ips = [local.fgt_ni_private_ip]
}
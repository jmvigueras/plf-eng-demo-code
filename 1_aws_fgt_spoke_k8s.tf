#------------------------------------------------------------------------------
# Create HUB AWS
# - VPC FGT hub
# - config FGT hub (FGCP)
# - FGT hub
# - Create test instances in bastion subnet
#------------------------------------------------------------------------------
// Create VPC for hub
module "aws_fgt_vpc" {
  source = "./modules/aws_fgt_vpc"

  prefix     = "${local.prefix}-fgt"
  admin_cidr = local.fgt_admin_cidr
  admin_port = local.fgt_admin_port
  region     = var.region

  vpc-sec_cidr = local.aws_spoke_cidr
}
// Create config for FGT hub (FGCP)
module "aws_fgt_config" {
  source = "./modules/aws_fgt_config"

  admin_cidr     = local.fgt_admin_cidr
  admin_port     = local.fgt_admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs = module.aws_fgt_vpc.subnet_az1_cidrs
  fgt_ni_ips   = module.aws_fgt_vpc.fgt_ni_ips

  license_type    = local.fgt_license_type
  fortiflex_token = local.fortiflex_token

  fgt_extra-config = join("\n", data.template_file.aws_fgt_extra_config.*.rendered)

  config_spoke = true
  hubs         = local.hubs
  spoke        = local.aws_spoke

  vpc-spoke_cidr = [local.aws_spoke_cidr]
}
# List of ports to create VIPs
locals {
  fgt_vips = [local.api_port, local.db_port, local.app_1_nodeport, local.app_2_nodeport]
}
# Create data template extra-config fgt
data "template_file" "aws_fgt_extra_config" {
  count    = length(local.fgt_vips)
  template = file("./templates/fgt_extra-config.tpl")
  vars = {
    external_ip   = module.aws_fgt_vpc.fgt_ni_ips["public"]
    mapped_ip     = local.master_ip
    external_port = local.fgt_vips[count.index]
    mapped_port   = local.fgt_vips[count.index]
    public_port   = "port1"
    private_port  = "port2"
    suffix        = local.fgt_vips[count.index]
  }
}
// Create FGT instances
module "aws_fgt" {
  source = "./modules/aws_fgt"

  prefix        = "${local.prefix}-spoke"
  region        = var.region
  instance_type = local.fgt_instance_type
  keypair       = aws_key_pair.keypair.key_name

  license_type = local.fgt_license_type
  fgt_build    = local.fgt_build

  fgt_ni_ids = module.aws_fgt_vpc.fgt_ni_ids
  fgt_config = module.aws_fgt_config.fgt_config
}
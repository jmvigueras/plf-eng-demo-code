# ------------------------------------------------------------------
# Create EIPs
# ------------------------------------------------------------------
# Create EIP active public NI
resource "aws_eip" "fgt_eip_public" {
  domain            = "vpc"
  network_interface = var.fgt_ni_ids["public"]
  tags = {
    Name = "${var.prefix}-fgt-eip-public"
  }
}
# ------------------------------------------------------------------
# Create Instance
# ------------------------------------------------------------------
resource "aws_instance" "fgt" {
  ami                  = var.license_type == "byol" ? data.aws_ami_ids.fgt_amis_byol.ids[0] : data.aws_ami_ids.fgt_amis_payg.ids[0]
  instance_type        = var.instance_type
  availability_zone    = var.region["az1"]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.fgt-apicall-profile.name
  user_data            = var.fgt_config
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted = true
  }
  ebs_block_device {
    encrypted   = true
    device_name = "/dev/sdb"
  }
  network_interface {
    device_index         = 0
    network_interface_id = var.fgt_ni_ids[var.fgt_ni_0]
  }
  network_interface {
    device_index         = 1
    network_interface_id = var.fgt_ni_ids[var.fgt_ni_1]
  }
  tags = {
    Name = "${var.prefix}-fgt"
  }
}
# ------------------------------------------------------------------
# Data
# ------------------------------------------------------------------
# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fgt_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND ${var.fgt_build}*"]
  }
}
# Get the last AMI Images from AWS MarektPlace FGT BYOL
data "aws_ami_ids" "fgt_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS ${var.fgt_build}*"]
  }
}
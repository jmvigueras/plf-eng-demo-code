#--------------------------------------------------------------------------
# Create cluster node
#--------------------------------------------------------------------------
# Create NI for node master
resource "aws_network_interface" "aws_node_master_ni" {
  subnet_id         = local.aws_nodes_subnet_id
  security_groups   = [local.aws_nodes_sg_id]
  private_ips       = [local.master_ip]
  source_dest_check = false
  tags = {
    Name = "${local.prefix}-ni-node-master"
  }
}
# Create EIP active public NI for node master
resource "aws_eip" "aws_node_master_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.aws_node_master_ni.id
  tags = {
    Name = "${local.prefix}-eip-node-master"
  }
}
# Deploy cluster master node
module "aws_node_master" {
  source = "./modules/aws_new_vm_ni"

  prefix  = "${local.prefix}-master"
  keypair = aws_key_pair.keypair.key_name

  instance_type = local.node_instance_type
  disk_size     = local.disk_size
  user_data     = data.template_file.aws_node_master.rendered

  ni_id = aws_network_interface.aws_node_master_ni.id
}

# Create data template for master node
data "template_file" "aws_node_master" {
  template = file("./templates/k8s-master.sh")
  vars = {
    cert_extra_sans = local.master_public_ip
    script          = data.template_file.aws_node_master_script.rendered
    k8s_version     = local.k8s_version
    db_pass         = local.db_pass
    linux_user      = local.linux_user
  }
}
data "template_file" "aws_node_master_script" {
  template = file("./templates/export-k8s-cluster-info.py")
  vars = {
    db_host         = local.db_host
    db_port         = local.db_port
    db_pass         = local.db_pass
    db_prefix       = local.db_prefix
    master_ip       = local.master_ip
    master_api_port = local.api_port
  }
}
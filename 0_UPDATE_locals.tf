locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "plf-eng"

  tags = {
    Deploy  = "demo platform-engineering"
    Project = "platform-engineering"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT Clusters
  #-----------------------------------------------------------------------------------------------------
  fgt_admin_port = "8443"
  fgt_admin_cidr = "0.0.0.0/0"

  fgt_license_type = "byol"
  fortiflex_token  = var.fortiflex_token

  fgt_build         = "build2702" // version 7.4.5
  fgt_instance_type = "c6i.large"

  #--------------------------------------------------------------------------------------------------
  # APPs details
  #--------------------------------------------------------------------------------------------------
  app = "plf-eng"
  # AWS Route53 zone
  route53_zone_name = "fortidemoscloud.com"
  # DNS names
  app_1_dns_name = "${local.app}-votes"   // special character "-" (not allowed "_" or ".")
  app_2_dns_name = "${local.app}-results" // special character "-" (not allowed "_" or ".")
  # variables used in deployment manifest
  app_1_nodeport = "31000"
  app_2_nodeport = "31001"

  #--------------------------------------------------------------------------------------------------
  # Github repo variables
  #--------------------------------------------------------------------------------------------------
  github_site          = "fortidemoscloud"
  github_repo_name_app = "${local.app}-catdogs"

  git_author_email = "fortidemoscloud@proton.me"
  git_author_name  = "fortidemoscloud"

  # Create secrets values to deploy APP in k8s cluster
  fgt_values = {
    HOST        = "${module.aws_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    PUBLIC_IP   = module.aws_fgt.fgt_eip_public
    EXTERNAL_IP = module.aws_fgt_vpc.fgt_ni_ips["public"]
    MAPPED_IP   = module.aws_node_master.vm["private_ip"]
    TOKEN       = trimspace(random_string.api_key.result)
  }
  # CLI command to get necessary values from k8s cluster
  k8s_values_cli = {
    KUBE_TOKEN       = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token"
    KUBE_HOST        = "echo ${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert"
  }
  # TOKEN and CERTIFICATE will need to be updated after deploy this terraform
  k8s_values = {
    KUBE_TOKEN       = "get-token-after-deploy"
    KUBE_HOST        = "${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "get-cert-after-deploy"
  }
  #-----------------------------------------------------------------------------------------------------
  # FortiWEB Cloud
  #-----------------------------------------------------------------------------------------------------
  # Fortiweb Cloud template ID
  fwb_cloud_template = "b4516b99-3d08-4af8-8df7-00246da409cf"
  # FortiWEB Cloud regions where deploy
  fortiweb_region = var.region["id"]
  # FortiWEB Cloud platform names
  fortiweb_platform = "AWS"

  #-----------------------------------------------------------------------------------------------------
  # K8S Clusters variables
  #-----------------------------------------------------------------------------------------------------
  worker_number        = 1
  k8s_version          = "1.24.10-00"
  node_master_cidrhost = 10 //Network IP address for master node
  disk_size            = 30

  linux_user         = "ubuntu"
  node_instance_type = "t3.2xlarge"
  master_public_ip   = module.aws_fgt.fgt_eip_public
  db_host_public_ip  = module.aws_fgt.fgt_eip_public
  master_ip          = cidrhost(local.aws_nodes_subnet_cidr, local.node_master_cidrhost)
  db_host            = cidrhost(local.aws_nodes_subnet_cidr, local.node_master_cidrhost)
  db_port            = 6379
  db_pass            = trimspace(random_string.api_key.result)
  db_prefix          = "aws"

  api_port = 6443

  #-----------------------------------------------------------------------------------------------------
  # FGT SDWAN HUB to connect
  #-----------------------------------------------------------------------------------------------------
  hub = [{
    id                = "hub"
    bgp_asn_hub       = "65000"
    bgp_asn_spoke     = "65000"
    vpn_cidr          = "10.10.10.0/24"
    vpn_psk           = var.aws_role_ext_id
    cidr              = "172.16.0.0/24"
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    mode_cfg          = true
    vpn_port          = "public"
    local_gw          = ""
  }]
  hubs = [{
    id                = local.hub[0]["id"]
    bgp_asn           = local.hub[0]["bgp_asn_hub"]
    external_ip       = var.hub_external_ip
    hub_ip            = cidrhost(local.hub[0]["vpn_cidr"], 1)
    site_ip           = "" // set to "" if VPN mode-cfg is enable
    hck_ip            = cidrhost(local.hub[0]["vpn_cidr"], 1)
    vpn_psk           = local.hub[0]["vpn_psk"]
    cidr              = local.hub[0]["cidr"]
    ike_version       = local.hub[0]["ike_version"]
    network_id        = local.hub[0]["network_id"]
    dpd_retryinterval = local.hub[0]["dpd_retryinterval"]
    sdwan_port        = local.hub[0]["vpn_port"]
  }]

  #-----------------------------------------------------------------------------------------------------
  # AWS FGT ONRAMP
  #-----------------------------------------------------------------------------------------------------
  aws_spoke_cidr = "172.20.0.0/24"
  aws_spoke = {
    id      = "spoke"
    cidr    = local.aws_spoke_cidr
    bgp_asn = local.hub[0]["bgp_asn_spoke"]
  }

  aws_nodes_subnet_id   = module.aws_fgt_vpc.subnet_az1_ids["bastion"]
  aws_nodes_subnet_cidr = module.aws_fgt_vpc.subnet_az1_cidrs["bastion"]
  aws_nodes_sg_id       = module.aws_fgt_vpc.nsg_ids["allow_all"]
}
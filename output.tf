#------------------------------------------------------------------------------
# FGT clusters
#------------------------------------------------------------------------------
output "fgt_url" {
  value = "https://${module.aws_fgt.fgt_eip_public}:${local.fgt_admin_port}"
}
output "fgt_id" {
  value = module.aws_fgt.fgt_id
}
output "fgt" {
  value = {
    mgmt_url  = "https://${module.aws_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    username  = "admin"
    password  = module.aws_fgt.fgt_id
    public_ip = module.aws_fgt.fgt_eip_public
    api_key   = trimspace(random_string.api_key.result)
  }
}
#------------------------------------------------------------------------------
# Kubernetes cluster export config
#------------------------------------------------------------------------------
output "kubectl_config" {
  value = {
    command_1 = "export KUBE_HOST=${local.master_public_ip}:${local.api_port}"
    command_2 = "export KUBE_TOKEN=$(redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token)"
    command_3 = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert | base64 --decode >${local.db_prefix}_ca.crt"
    command_4 = "kubectl get nodes --token $KUBE_TOKEN -s https://$KUBE_HOST --certificate-authority ${local.db_prefix}_ca.crt"
  }
}
#------------------------------------------------------------------------------
# Kubernetes cluster nodes
#------------------------------------------------------------------------------
output "aws_node_master" {
  value = module.aws_node_master.vm
}
#------------------------------------------------------------------------------
# FGT APP details 
#------------------------------------------------------------------------------
# FGT values
output "fgt_values" {
  sensitive = true
  value     = local.fgt_values
}
#-----------------------------------------------------------------------------------------------------
# K8S Clusters (CLI commands to retrieve data from redis)
#-----------------------------------------------------------------------------------------------------
# Commands to get K8S clusters variables
output "k8s_values_cli" {
  value = local.k8s_values_cli
}
output "k8s_cert_cli" {
  value = local.k8s_values_cli["KUBE_TOKEN"]
}
output "k8s_token_cli" {
  value = local.k8s_values_cli["KUBE_CERTIFICATE"]
}

#-----------------------------------------------------------------------------------------------------
# K8S Clusters (CLI commands to retrieve data from redis)
#-----------------------------------------------------------------------------------------------------
output "github_repo_app" {
  value = github_repository.repo_app.html_url
}
output "app_1_url" {
  value = "http://${local.app_1_dns_name}.${data.aws_route53_zone.route53_zone.name}"
}
output "app_2_url" {
  value = "http://${local.app_2_dns_name}.${data.aws_route53_zone.route53_zone.name}"
}
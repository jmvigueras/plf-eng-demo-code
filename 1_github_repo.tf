#-----------------------------------------------------------------------------------------------------
# Create Github repo and actions secret
#-----------------------------------------------------------------------------------------------------
# Create APP 1 repo
resource "github_repository" "repo_app" {
  name        = local.github_repo_name_app
  description = "An example repository created using Terraform"
}
# Create K8S master secrets - Repo 1
module "repo_app_k8s" {
  depends_on = [github_repository.repo_app]
  source     = "./modules/github-secrets"

  prefix     = "${upper(local.db_prefix)}_"
  repository = github_repository.repo_app.name
  secrets    = local.k8s_values
}
module "repo_app_fgt" {
  depends_on = [github_repository.repo_app]
  source     = "./modules/github-secrets"

  prefix     = "${upper(local.db_prefix)}_"
  repository = github_repository.repo_app.name
  secrets    = local.fgt_values
}
#-----------------------------------------------------------------------------------------------------
# APP 1 local repo-content - VotingAPP
#-----------------------------------------------------------------------------------------------------
# Create Github actions workflow from template
data "template_file" "github_actions_workflow_app" {
  template = file("./templates/github-actions-workflow.tpl")
  vars = {
    deploy_k8s = data.template_file.github_actions_workflow_csps_app.rendered
  }
}
# GitHub actions APP 1
data "template_file" "github_actions_workflow_csps_app" {
  template = file("./templates/github-actions-workflow_k8s.tpl")
  vars = {
    prefix = "${upper(local.db_prefix)}_"
  }
}
# GitHub actions APP 1 yaml
resource "local_file" "github_actions_workflow_app" {
  content  = data.template_file.github_actions_workflow_app.rendered
  filename = "./repo_app/.github/workflows/main.yaml"
}
# Create k8s manifest APP 1
data "template_file" "k8s_manifest_deployment_app" {
  template = file("./templates/k8s-voting-app.yaml.tpl")
  vars = {
    votes_nodeport   = local.app_1_nodeport
    results_nodeport = local.app_2_nodeport
  }
}
# Create k8s manifest APP 1 yaml
resource "local_file" "k8s_manifest_deployment_app" {
  content  = data.template_file.k8s_manifest_deployment_app.rendered
  filename = "./repo_app/manifest/voting-app.yaml"
}
# Create file for FortiDevSec manifest from template
data "template_file" "fdevsec_file_app" {
  template = file("./templates/fdevsec.yaml.tpl")
  vars = {
    devsec_org = var.fortidevsec_org
    devsec_app = var.fortidevsec_app
  }
}
# Create file for FortiDevSec manifest from template
resource "local_file" "fdevsec_file_app" {
  content  = data.template_file.fdevsec_file_app.rendered
  filename = "./repo_app/fdevsec.yaml"
}
#-----------------------------------------------------------------------------------------------------
# Upload content to new repo
#-----------------------------------------------------------------------------------------------------
# Set Git credentials
resource "null_resource" "set_git_config" {
  provisioner "local-exec" {
    command = "git config --global user.email ${local.git_author_email} && git config --global user.name ${local.git_author_name}"
  }
}
# Upload content to new repo APP 1
resource "null_resource" "upload_repo_code_app" {
  depends_on = [github_repository.repo_app, module.repo_app_k8s, module.repo_app_fgt, local_file.github_actions_workflow_app, null_resource.set_git_config]
  provisioner "local-exec" {
    command = "cd ./repo_app && rm -rf .git && git init && git add . && git commit -m 'first commit' && git branch -M master && git remote add origin https://${var.github_token}@github.com/${local.github_site}/${local.github_repo_name_app}.git && git push -u origin master"
  }
}
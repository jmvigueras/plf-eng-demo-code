#-----------------------------------------------------------------------------------------------------
# Create new APP in FortiWEB Cloud
#-----------------------------------------------------------------------------------------------------
# Create APP 1 FWEB Cloud APP
data "template_file" "fwb_cloud_app_1" {
  template = file("./templates/fwb_cloud_new_app.tpl")
  vars = {
    token       = var.fwb_cloud_token
    region      = local.fortiweb_region
    app_name    = local.app_1_dns_name
    domain_name = "${local.app_1_dns_name}.${local.route53_zone_name}"
    zone_name   = local.route53_zone_name
    server_ip   = local.fgt_values["PUBLIC_IP"]
    server_port = local.app_1_nodeport
    template_id = local.fwb_cloud_template
    file_name   = "${local.app_1_dns_name}_cname_record.txt"
    platform    = local.fortiweb_platform
  }
}
resource "null_resource" "fwb_cloud_app_1" {
  provisioner "local-exec" {
    command = data.template_file.fwb_cloud_app_1.rendered
  }
}
# Create APP 2 FWEB Cloud APP
data "template_file" "fwb_cloud_app_2" {
  template = file("./templates/fwb_cloud_new_app.tpl")
  vars = {
    token       = var.fwb_cloud_token
    region      = local.fortiweb_region
    app_name    = local.app_2_dns_name
    domain_name = "${local.app_2_dns_name}.${local.route53_zone_name}"
    zone_name   = local.route53_zone_name
    server_ip   = local.fgt_values["PUBLIC_IP"]
    server_port = local.app_2_nodeport
    template_id = local.fwb_cloud_template
    file_name   = "${local.app_2_dns_name}_cname_record.txt"
    platform    = local.fortiweb_platform
  }
}
resource "null_resource" "fwb_cloud_app_2" {
  provisioner "local-exec" {
    command = data.template_file.fwb_cloud_app_2.rendered
  }
}
#-----------------------------------------------------------------------------------------------------
# Create new Route53 record
#-----------------------------------------------------------------------------------------------------
# Read Route53 Zone info
data "aws_route53_zone" "route53_zone" {
  name         = "${local.route53_zone_name}."
  private_zone = false
}
# Read FortiWEB new APP CNAME file after FWB Cloud command be applied
data "local_file" "fwb_cloud_app_1_cname" {
  depends_on = [null_resource.fwb_cloud_app_1]
  filename   = "${local.app_1_dns_name}_cname_record.txt"
}
data "local_file" "fwb_cloud_app_2_cname" {
  depends_on = [null_resource.fwb_cloud_app_2]
  filename   = "${local.app_2_dns_name}_cname_record.txt"
}
# Create Route53 record entry with FWB APP CNAME
resource "aws_route53_record" "record_type_cname_app_1" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${local.app_1_dns_name}.${data.aws_route53_zone.route53_zone.name}"
  type    = "CNAME"
  ttl     = "30"
  records = [data.local_file.fwb_cloud_app_1_cname.content]
}
# Create Route53 record entry with FWB APP CNAME
resource "aws_route53_record" "record_type_cname_app_2" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "${local.app_2_dns_name}.${data.aws_route53_zone.route53_zone.name}"
  type    = "CNAME"
  ttl     = "30"
  records = [data.local_file.fwb_cloud_app_2_cname.content]
}
output "fgt_id" {
  value = aws_instance.fgt.id
}

output "fgt_eip_public" {
  value = aws_eip.fgt_eip_public.public_ip
}

output "fgt_eip_mgmt" {
  value = aws_eip.fgt_eip_public.public_ip
}
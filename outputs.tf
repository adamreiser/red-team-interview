output "Session" {
  value = "session uuid: ${var.session}"
}

output "Notes" {
  value = "Remember that it can take a few seconds for hosts to become available!"
}

output "kali" {
  value = { "public ip" = aws_eip.kali.public_ip, "private ip" = aws_instance.kali.private_ip }
}

output "ubuntu" {
    value = { "private ip" = module.scenario.ubuntu.private_ip}
}

/*
output "nat_gateway_ip" {
    value = { "private ip" = aws_nat_gateway.nat.private_ip}
}
*/

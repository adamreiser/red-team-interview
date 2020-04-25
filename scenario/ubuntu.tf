resource "aws_instance" "ubuntu" {
  ami               = "ami-0e2e3e63c545211e2"
  instance_type     = "t2.micro"
  availability_zone = var.az
  key_name          = var.interview_key.key_name
  tags = {
    role    = "interview"
    name    = "ubuntu"
    session = var.session
  }

  volume_tags = {
    role    = "interview"
    name    = "ubuntu"
    session = var.session
  }

  user_data = templatefile("${path.module}/ubuntu.yml", { hostname = "ubuntu", domain=var.domain_name, interviewer_key = var.interview_key.public_key })

  network_interface {
    network_interface_id = aws_network_interface.ubuntu.id
    device_index         = 0
  }

}

resource "aws_network_interface" "ubuntu" {
  subnet_id       = var.subnet_id
  private_ips     = ["10.0.0.12"]
  security_groups = [var.int_security_group_id, var.ext_security_group_id]
}

resource "aws_route53_record" "ubuntu" {
  zone_id = var.zone_id
  name    = "ubuntu.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["10.0.0.12"]
}

resource "aws_route53_record" "ubuntu_ptr" {
  zone_id = var.rev_zone_id
  name    = "12.0.0.10.in-addr.arpa"
  type    = "PTR"
  ttl     = "300"
  records = ["ubuntu.${var.domain_name}"]
}

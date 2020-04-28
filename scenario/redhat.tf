resource "aws_instance" "redhat" {
  ami               = "ami-0062814abe5ca3369"
  instance_type     = "t3.micro"
  availability_zone = var.az
  key_name          = var.interview_key.key_name
  tags = {
    role    = "interview"
    name    = "redhat"
    session = var.session
  }

  volume_tags = {
    role    = "interview"
    name    = "redhat"
    session = var.session
  }

  user_data = templatefile("${path.module}/cloud-init.yml", { hostname = "redhat", domain=var.domain_name, interviewer_key = var.interview_key.public_key })

  network_interface {
    network_interface_id = aws_network_interface.redhat.id
    device_index         = 0
  }

}

resource "aws_network_interface" "redhat" {
  subnet_id       = var.subnet_id
  private_ips     = ["10.0.0.17"]
  security_groups = [var.int_security_group_id, var.ext_security_group_id]
}

resource "aws_route53_record" "redhat" {
  zone_id = var.zone_id
  name    = "redhat.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["10.0.0.17"]
}

resource "aws_route53_record" "redhat_ptr" {
  zone_id = var.rev_zone_id
  name    = "17.0.0.10.in-addr.arpa"
  type    = "PTR"
  ttl     = "300"
  records = ["redhat.${var.domain_name}"]
}

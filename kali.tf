resource "aws_instance" "kali" {
  ami               = "${var.kali_ami}"
  instance_type     = "i3.large"
  availability_zone = var.az
  key_name          = aws_key_pair.interview_key.key_name
  tags = {
    role    = "interview"
    name    = "kali"
    session = var.session
  }
  volume_tags = {
    role    = "interview"
    name    = "kali"
    session = var.session
  }
  user_data = templatefile("${path.module}/kali.yml", { hostname = "kali", interviewer_key = aws_key_pair.interview_key.public_key, candidate_key = var.candidate_key })

  network_interface {
    network_interface_id = aws_network_interface.kali.id
    device_index         = 0
  }

}

resource "aws_eip_association" "kali_eip_assoc" {
  instance_id   = "${aws_instance.kali.id}"
  allocation_id = "${aws_eip.kali.id}"
}

resource "aws_eip" "kali" {
  vpc = true
}

resource "aws_network_interface" "kali" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.0.7"]
  security_groups = [aws_security_group.int.id, aws_security_group.ext.id]
}

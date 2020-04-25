module "scenario" {
  source                = "./scenario"
  interview_key         = aws_key_pair.interview_key
  candidate_key         = var.candidate_key
	zone_id   						= aws_route53_zone.interview.zone_id
  rev_zone_id           = aws_route53_zone.interview_reverse.zone_id
  int_security_group_id = aws_security_group.int.id
  ext_security_group_id = aws_security_group.ext.id
  session               = var.session
  region                = var.region
  az                    = var.az
  domain_name           = var.domain_name
  vpc_id                = aws_vpc.main.id
  subnet_id             = aws_subnet.main.id
}

provider "aws" {
  region  = var.region
  version = "~> 2.30"
}

provider "local" {
  version = "~> 1.4"
}

resource aws_vpc "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    role    = "interview"
    session = var.session
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name          = var.domain_name
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = {
    role = "interview"
    session = var.session
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

resource "aws_route53_zone" "interview" {
  name = var.domain_name
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_zone" "interview_reverse" {
  name = "0.10.in-addr.arpa"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
}

resource "aws_eip" "main" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.main.id}"
  subnet_id     = "${aws_subnet.main.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.0.0/16"
  map_public_ip_on_launch = false
  availability_zone       = var.az
}

# security groups for attack targets
resource "aws_security_group" "int" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "ext" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "interview_key" {
  key_name_prefix = "interview_key"
  public_key      = "${file(".ssh/${var.session}.pem.pub")}"
}

# TODO modules should handle their own ssh configs
locals {
  kali_ssh_conf = join("", formatlist("Host kali\n\tHostname %s\n\tUser root\n\tIdentityFile .ssh/${var.session}.pem\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile .ssh/${var.session}_known_hosts\n\tIdentitiesOnly yes\n\n", aws_eip.kali.public_ip))
  ubuntu_ssh_conf = join("", formatlist("Host ubuntu\n\tHostname %s\n\tUser root\n\tIdentityFile .ssh/${var.session}.pem\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile .ssh/${var.session}_known_hosts\n\tProxyJump kali\n\tIdentitiesOnly yes\n\n", module.scenario.ubuntu.private_ip))
}

resource "local_file" "ssh_config" {
  filename = "${path.module}/.ssh/${var.session}_config"
  content         = join("", [local.kali_ssh_conf, local.ubuntu_ssh_conf])
  file_permission = "0600"
}

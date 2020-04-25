variable "candidate_key" {
  description = "ssh key provided by the candidate"
  default     = ""
}

variable "interview_key" {
  description = "interviewer's pubkey (generated)"
  default     = ""
}

variable "zone_id" {
  description = "DNS zone ID"
  default     = ""
}

variable "rev_zone_id" {
  description = "Reverse DNS zone ID"
  default     = ""
}

variable "domain_name" {
  description = "Domain name"
  default     = ""
}

variable "int_security_group_id" {
  description = "AWS security group ID"
  default     = ""
}

variable "ext_security_group_id" {
  description = "AWS security group ID"
  default     = ""
}

variable "vpc_id" {
  description = "AWS VPC ID"
  default     = ""
}

variable "subnet_id" {
  description = "AWS subnet ID"
  default     = ""
}

variable "session" {
  description = "UUID"
  default     = "default_session"
}

variable "region" {
  description = "Region"
  default     = ""
}

variable "az" {
  description = "Availability zone"
  default     = ""
}

# Don't edit this. Define key in .env instead
variable "candidate_key" {
  description = "ssh key provided by the candidate"
  default     = ""
}

variable "domain_name" {
  description = "Private domain"
  default     = "example.com"
}

variable "kali_ami" {
  description = "kali AMI"
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

# Don't change this -- modify .env to set a different zone
variable "az" {
  description = "Availability zone"
  default     = ""
}

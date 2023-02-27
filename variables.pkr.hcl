variable "subnet_id" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "ssh_private_key_file" {
  type    = string
  default = ""
}

variable "root_volume_size_gb" {
  description = "The size of the volume, in GiB"
  type        = string
  default     = "30"
}

variable "volume_type" {
  description = "The volume type. gp2 for General Purpose (SSD) volumes, io1 for Provisioned IOPS (SSD) volumes, st1 for Throughput Optimized HDD, sc1 for Cold HDD, and standard for Magnetic volumes."
  type        = string
  default     = "gp2"
}

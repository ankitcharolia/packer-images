# This packer file is using HCL syntax. It can also be written in json template.
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu2204-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-west-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  # vpc_id is needed when default VPN has been deleted
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id


  tags = {
    "Name"            = "{{user `ami_name`}}",
    "created"         = "${local.timestamp}",
    "build_region"    = "{{ .BuildRegion }}",
    "source_ami_id"   = "{{ .SourceAMI }}",
    "source_ami_name" = "{{ .SourceAMIName }}",
  }
}

build {
  name = "packer-ubuntu-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = ["echo Connected via SSM at '${build.User}@${build.Host}:${build.Port}'"]
  }

  provisioner "shell" {
    inline = [
      "echo Updating Image",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install ansible git",
    ]
  }
}


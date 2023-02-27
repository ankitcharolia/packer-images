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
  vpc_id                  = var.vpc_id
  subnet_id               = var.subnet_id
  associate_public_ip_address = true
  ssh_interface           = "public_ip"
  # Reference: https://github.com/hashicorp/packer-plugin-amazon/blob/main/docs-partials/builders/aws-ssh-differentiation-table.mdx
  ssh_keypair_name        = "acharolia"
  ssh_private_key_file    = var.ssh_private_key_file
  ssh_timeout             = "10m"
  # Reference: https://github.com/hashicorp/packer-plugin-amazon/blob/f8c2e6ff7229a8abd729a89e1b8a6ed1041e368c/docs/builders/ebs.mdx
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size_gb
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  # Reference: https://github.com/hashicorp/packer-plugin-amazon/blob/f8c2e6ff7229a8abd729a89e1b8a6ed1041e368c/docs/builders/ebs.mdx#tag-example
  tags = {
    Name            = "Ubuntu",
    os_version      = "22.04"
    created         = "${local.timestamp}",
    build_region    = "{{ .BuildRegion }}",
    source_ami_id   = "{{ .SourceAMI }}",
    source_ami_name = "{{ .SourceAMIName }}",
    Extra           = "{{ .SourceAMITags.TagName }}",
  }
}

build {
  name = "packer-ubuntu-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Fix: https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201
  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections" ]
  }

  provisioner "shell" {
    inline = [
      "echo Updating Image",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install ansible git -y",
    ]
  }
}


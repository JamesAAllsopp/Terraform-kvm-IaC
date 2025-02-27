terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
     version = "0.7.6"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

variable "diskBytes" { default = 1024*1024*1024*20 }

variable "name" { default = "feov-ldap"} 

# adapt the build number 
resource "libvirt_volume" "base-feov-ldap" {
  name   = "base-feov-ldap.qcow2"
  pool   = "default"
  source = "/home/james/Downloads/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "feov-ldap-qcow2" {
  name   = "feov-ldap.qcow2"
  pool   = "pool"
  format = "qcow2"
  size = var.diskBytes
  base_volume_id = libvirt_volume.base-feov-ldap.id 
}

#data "template_file" "user_data" {
#  template = file("${path.module}/cloud_init.cfg")
#}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "ldap_server.iso"
  user_data      = templatefile("${path.module}/cloud_init.cfg", { fqdn = var.name}) #data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

# Create the machine
resource "libvirt_domain" "domain-feov-ldap" {
  name   = var.name #"terraform-testing"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id
  #qemu_agent = true
  network_interface {
    network_name = "VirtBridge"
    #wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.feov-ldap-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output ip {
  value = "${libvirt_domain.domain-feov-ldap.name[*]}"
}


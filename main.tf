provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_vcenter

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.vm_cpus
  memory   = var.vm_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "${var.vm_name}.vmdk"
    size = var.vm_disk
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = var.vm_linked_clone

    customize {
      timeout = "20"

      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = var.vm_netmask
      }

      ipv4_gateway    = var.vm_gateway
      dns_server_list = [var.vm_dns]
    }
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir ~/.ssh"
    ]
    connection {
      type     = "ssh"
      user     = var.vm_user
      password = var.vm_password
      host     = var.vm_ip
    }
  }
  provisioner "file" {
    source      = "~/.ssh/id_rsa.pub"
    destination = "~/.ssh/authorized_keys"
  
    connection {
      type     = "ssh"
      user     = var.vm_user
      password = var.vm_password
      host     = var.vm_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook resize.yml -i ${var.vm_ip}, -u ${var.vm_user} --private-key=~/.ssh/id_rsa -vvv"
  }
}

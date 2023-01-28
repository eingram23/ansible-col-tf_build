provider "google" {
  credentials = "/terraform/creds.json"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
}

provider "vault" {
}
data "vault_generic_secret" "vsphere_username" {
  path = "secret/vsphere/vcsa"
}
data "vault_generic_secret" "vsphere_password" {
  path = "secret/vsphere/vcsa"
}
data "vault_generic_secret" "ssh_username" {
  path = "secret/ssh/ansible"
}
data "vault_generic_secret" "ssh_password" {
  path = "secret/ssh/ansible"
}

provider "vsphere" {
  user                 = data.vault_generic_secret.vsphere_username.data["vsphere_username"]
  password             = data.vault_generic_secret.vsphere_password.data["vsphere_password"]
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  count     = length(var.vsphere_datastore_list)
  name          = element(var.vsphere_datastore_list, count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_storage_policy" "policy" {
  name          = var.vsphere_storage_policy
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  count = length(var.vsphere_network_list)
  name          = element(var.vsphere_network_list, count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  
  count = length(var.vm_name_list)
  name  = element(var.vm_name_list, count.index)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore[count.index].id
  storage_policy_id = data.vsphere_storage_policy.policy.id
  folder           = "/HomeLab Datacenter/vm/${var.vm_folder_name}"
  firmware         = "efi"
  efi_secure_boot_enabled = var.vm_efi_secure

  num_cpus           = var.vm_cpu
  memory             = var.vm_ram
  memory_reservation = var.vm_ram
  guest_id           = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network[count.index].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  dynamic "disk" {
    for_each = var.vm_disks_list
    content {
      label = disk.value["label"]
      unit_number = disk.value["id"]
      size = disk.value["size"]
      thin_provisioned = disk.value["thin_provisioned"]
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = element(var.vm_name_list, count.index)
        domain = element(var.dns_suffix_list, count.index)
      }

      network_interface {
        ipv4_address = element(var.ip_address_list, count.index)
        ipv4_netmask = 24
      }

      ipv4_gateway = element(var.ip_gateway_list, count.index)
      # ipv4_gateway    = var.ip_gateway
      dns_server_list = var.dns_server_list
      dns_suffix_list = var.dns_suffix_list
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }
}

resource "null_resource" "vm" {

  triggers = {
    ip = join(",", vsphere_virtual_machine.vm.*.default_ip_address)
  }
  count = length(var.vm_name_list)

  connection {
    type     = "ssh"
    agent    = false
    # host     = self.clone.0.customize.0.network_interface.0.ipv4_address
    host     = element(var.ip_address_list, count.index)
    user     = data.vault_generic_secret.ssh_username.data["ssh_username"]
    password = data.vault_generic_secret.ssh_password.data["ssh_password"]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/post_script.sh"
    destination = "/home/ansible/post_script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # "echo ${data.vault_generic_secret.ssh_password.data["ssh_password"]} | sudo -S subscription-manager register --force --username ${data.vault_generic_secret.sub_email.data["sub_email"]} --password ${data.vault_generic_secret.sub_password.data["sub_password"]} --auto-attach",
      "chmod +x /home/ansible/post_script.sh",
      "echo ${data.vault_generic_secret.ssh_password.data["ssh_password"]} | sudo -S /home/ansible/post_script.sh"
    ]
  }
}


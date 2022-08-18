# Deploy RHEL8.5 VMs

provider "vault" {
}
data "vault_generic_secret" "vsphere_username" {
  path = "secret/vsphere/vcsa"
}
data "vault_generic_secret" "vsphere_password" {
  path = "secret/vsphere/vcsa"
}
data "vault_generic_secret" "win_password" {
  path = "secret/win/administrator"
}
data "vault_generic_secret" "hladmin_username" {
  path = "secret/win/homelab"
}
data "vault_generic_secret" "hladmin_password" {
  path = "secret/win/homelab"
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
  count         = length(var.vsphere_datastore_list)
  name          = element(var.vsphere_datastore_list, count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  count         = length(var.vsphere_network_list)
  name          = element(var.vsphere_network_list, count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "folder" {
  path          = "/HomeLab Datacenter/vm/WindowsHL"
}

resource "vsphere_virtual_machine" "vm" {

  count = length(var.vm_name_list)
  name  = element(var.vm_name_list, count.index)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore[count.index].id
  folder           = var.vm_folder_name
  firmware         = "efi"

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

  disk {
    label       = "disk1"
    size        = "40"
    unit_number = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name         = element(var.vm_name_list, count.index)
        admin_password        = data.vault_generic_secret.win_password.data["win_password"]
        full_name             = var.full_name
        organization_name     = var.organization_name
        auto_logon            = "true"
        time_zone             = var.time_zone
        join_domain           = var.dns_domain
        domain_admin_user     = data.vault_generic_secret.hladmin_username.data["hladmin_username"]
        domain_admin_password = data.vault_generic_secret.hladmin_password.data["hladmin_password"]
        # run_once_command_list = ""
      }

      network_interface {
        ipv4_address = element(var.ip_address_list, count.index)
        ipv4_netmask = 24
      }

      ipv4_gateway    = element(var.ip_gateway_list, count.index)
      dns_server_list = var.dns_server_list
      # dns_suffix_list = var.dns_suffix_list
    }
  }

  # connection {
  #   host     = self.clone.0.customize.0.network_interface.0.ipv4_address
  #   # timeout  = "15m"
  #   type     = "winrm"
  #   port     = 5985
  #   insecure = true
  #   https    = false
  #   use_ntlm = true
  #   user     = "administrator"
  #   password = "NL2B1r13"
  #   # password = data.vault_generic_secret.win_password.data["win_password"]
  #   # user     = data.vault_generic_secret.hladmin_username.data["hladmin_username"]
  #   # password = data.vault_generic_secret.hladmin_password.data["hladmin_password"]
  # }

  # provisioner "file" {
  #   source      = "/Users/edwardingram/code/Terraform/files/powershell/"
  #   destination = "c:/temp"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "powershell -ExecutionPolicy Bypass -File c:\\temp\\config.ps1"
  #   ]
  # }
}

resource "null_resource" "vm" {
  triggers = {
    ip = join(",", vsphere_virtual_machine.vm.*.default_ip_address)
  }
  count = length(var.vm_name_list)

  connection {
    # host = self.clone.0.customize.0.network_interface.0.ipv4_address
    host     = element(var.ip_address_list, count.index)
    type     = "winrm"
    port     = 5985
    insecure = true
    https    = false
    use_ntlm = true
    user     = data.vault_generic_secret.hladmin_username.data["hladmin_username"]
    password = data.vault_generic_secret.hladmin_password.data["hladmin_password"]
  }

  provisioner "file" {
    source      = "/Users/edwardingram/code/Terraform/files/powershell/"
    destination = "c:/temp"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -ExecutionPolicy Bypass -File c:\\temp\\config.ps1"
    ]
  }
}

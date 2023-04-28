terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "google" {
  credentials = "/terraform/creds.json"
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
}

provider "vault" {
}

data "vault_generic_secret" "token-id" {
  path = "secret/proxmox/terraform"
}

data "vault_generic_secret" "secret" {
  path = "secret/proxmox/terraform"
}

data "vault_generic_secret" "ssh_password" {
  path = "secret/ssh/ansible"
}

data "vault_generic_secret" "ssh_priv_key" {
  path = "secret/ssh/ansible"
}

provider "proxmox" {
  pm_api_token_id                 = data.vault_generic_secret.token-id.data["token-id"]
  pm_api_token_secret             = data.vault_generic_secret.secret.data["secret"]
  pm_api_url       = var.proxmox_url
  pm_tls_insecure = true

  # Extra logging
  # pm_log_enable = true
  # pm_log_file = "terraform-plugin-proxmox.log"
  # pm_debug = true
  # pm_log_levels = {
  #   _default = "debug"
  #   _capturelog = ""
}

resource "proxmox_vm_qemu" "vm" {
  
  count = length(var.vm_name_list)
  name  = element(var.vm_name_list, count.index)
  target_node = var.proxmox_node

  clone = var.proxmox_template
  full_clone = "true"

  # VM Settings
  agent = 1
  os_type = "cloud-init"
  cores = var.vm_cores
  sockets = 1
  cpu = "host"
  memory = var.vm_ram

  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = var.vlan
  }

  disk {
    slot = 0
    size = var.disk_size
    type = "scsi"
    storage = var.storage
    ssd = 1
    discard = "on" # Enable thin provisioning
  }

  ipconfig0 = "ip=${element(var.ip_address_list, count.index)}/24,gw=${element(var.ip_gateway_list, count.index)}"
  ciuser = "ansible"
  cipassword = "${data.vault_generic_secret.ssh_password.data["ssh_password"]}"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}


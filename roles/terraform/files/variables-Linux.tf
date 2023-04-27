variable "gcp_project" {
  default = "proj-yc-srv1"
}

variable "gcp_region" {
  default = "us-west1"
}

variable "gcp_zone" {
  default = "us-west1-a"
}

variable login_approle_role_id {}
variable login_approle_secret_id {}

variable "vsphere_username" {
  default   = ""
  sensitive = true
}

variable "vsphere_password" {
  default   = ""
  sensitive = true
}

variable "vsphere_server" {
  default = "vcsa-1.local.lan"
}

variable "vm_name_list" {
    type=list(any)
}

variable "vm_ram" {
}

variable "vm_cpu" {
}

variable "vsphere_datacenter" {
  default = "HomeLab Datacenter"
}

variable "vsphere_compute_cluster" {
  default = "Intel NUC10 Cluster"
}

variable "vsphere_datastore_list" {
    type = list(any)
}

variable "vsphere_storage_policy" {
  default = ""
}

variable "vsphere_template" {
  default = ""
}

variable "vm_folder_name" {
  default = ""
}

variable "vm_disks_list" {
  default = []
}

variable "esxi_hosts" {
  default = []
}

variable "network_interfaces" {
  description = "vmnics to be used"
  default     = []
}

variable "vsphere_network_list" {
    type = list(any)
}

variable "port_group_name" {
  default = ""
}

variable "vsphere_dvs" {
  default = ""
}

variable "iso_path" {
  default = ""
}

variable "vsphere_hardware_version" {
  default = ""
}

variable "ssh_username" {
  default   = ""
  type      = string
  sensitive = true
}

variable "ssh_password" {
  default   = ""
  type      = string
  sensitive = true
}

variable "ip_address_list" {
  type    = list(any)
  default = []
}

variable "ip_gateway_list" {
  type = list(any)
}

variable "dns_server_list" {
  type = list(any)
  default = ["192.168.1.250",
  "192.168.1.251"]
}

variable "dns_suffix_list" {
  type    = list(any)
  default = ["local.lan"]
}

variable "workgroup" {
  default = ""
}

variable "vm_efi_secure" {
  default = false
}
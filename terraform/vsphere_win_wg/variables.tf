variable "vsphere_username" {
  default   = ""
  sensitive = true
}

variable "vsphere_password" {
  default   = ""
  sensitive = true
}

variable "vsphere_server" {
  default = "vcsa.local.lan"
}

variable "vm_name_list" {
  type = list(any)
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

variable "vsphere_template" {
  default = ""
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

variable "win_password" {
  default   = ""
  type      = string
  sensitive = true
}

variable "ip_address_list" {
  type    = list(any)
  default = []
}

variable "ip_gateway_list" {
  type    = list(any)
  default = []
}

variable "dns_server_list" {
  type    = list(any)
  default = ["10.10.0.10"]
}

variable "dns_domain" {}

variable "full_name" {
  type    = string
  default = "Edward Ingram"
}

variable "organization_name" {
  type    = string
  default = "HomeLab"
}

variable "time_zone" {
  type    = string
  default = "004"
}

variable "workgroup" {}

variable "vm_folder_name" {}

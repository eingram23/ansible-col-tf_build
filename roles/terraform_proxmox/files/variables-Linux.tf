variable "gcp_project" {
  default = "yc-srv1-proj"
}

variable "gcp_region" {
  default = "us-west1"
}

variable "gcp_zone" {
  default = "us-west1-a"
}

variable "proxmox_id" {
  default = ""
  sensitive = true
}

variable "proxmox_secret" {
  default   = ""
  sensitive = true
}

variable "proxmox_url" {
  default = "https://pve1.local.lan:8006/api2/json"
}

variable "proxmox_node" {
  default = "pve1"
}

variable "vm_name_list" {
    type=list(any)
}

variable "vm_ram" {
}

variable "vm_cores" {
}

variable "disk_size" {}

variable "storage" {}

variable "vlan" {}

variable "proxmox_template" {
  default = ""
}

variable "ssh_password" {
  default   = ""
  type      = string
  sensitive = true
}

variable "ssh_priv_key" {
  default   = ""
  type      = string
  sensitive = true
}

variable "ip_address_list" {
  type    = list(any)
  default = []
}

variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwwvtM55JcbHVFcpq6uJAZ5qZj4z1FI0fYzTwLOm7Xef9kCYKtwBqNH/ixWfYbeM3qKfwP3JrdldEVi5cJauWt8YzHnAAeBcKkHJk47rI26P+DuLfnfnrX5PkIkwX7dUl4C/4ShJNsgTquI9xdwGWHwGpp9NZNTx+Z02A7/ANpCVjGYqDAahlhXYXAr3wEJ7wZucGgbNF8Ru/vlhqdYBXPKxcTW+rIT+wt6D+48bmmwWRZw7W06EBPYSArpiNuonT4ChFb8Zz8ZcFpAde71ya12GjPnroH3Fq53+3t+CTINcMEJPjiOBUy+q61L7QpCVKW9LLhqpxsInUKtZjPDdP080htSPDstoHEDGqqdPWrszfazIwEJZkoLp6eMnEWztB+DNNGuZT4l/tGs6uSL9tuUjuitLSO5zPxrY2fPJm4iZrx294UrmPooUm3LNojlgZ96N9FxPxx1DBg8x6PJgRF24RmHh1oAwBToFn8BwIfjdCe728b1qsxH/LUCKiZrnc= edwardingram@Edwards-MBP.local.lan"
}

variable "ip_gateway_list" {
  type = list(any)
}

variable "vm_disks_list" {
  default = []
}

variable "proxmox_url" {
  default = "https://proxmox.billv.ca"
  type = string
}

variable "proxmox_user" {
  default = "terraform@pve"
  type = string
}

variable "proxmox_password" {
  sensitive = true
  type = string
}
variable "resource_group" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "vm_name" {}
variable "admin_username" {}
variable "ssh_public_key" {}
variable "vm_size" {}
variable "vm_publisher" {}
variable "vm_offer" {}
variable "vm_sku" {}
variable "vm_version" {}
variable "vnet_resource_group" {
  description = "Resource group where VNET exists"
  type        = string
}
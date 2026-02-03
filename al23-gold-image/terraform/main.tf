terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ----------------------------
# Existing Resource Group
# ----------------------------
data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

# ----------------------------
# Existing VNET
# ----------------------------
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

# ----------------------------
# Existing Subnet
# ----------------------------
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.vnet_resource_group
}

# ----------------------------
# Public IP
# ----------------------------
# resource "azurerm_public_ip" "pip" {
#   name                = "${var.vm_name}-pip"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   allocation_method   = "Dynamic"
#   sku                 = "Basic"
# }

# ----------------------------
# Network Interface
# ----------------------------
# resource "azurerm_network_interface" "nic" {
#   name                = "${var.vm_name}-nic"
#   location            = eastus2
#   resource_group_name = data.azurerm_resource_group.rg.name 
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = "eastus2"
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id        = azurerm_public_ip.pip.id
  }
}


# ----------------------------
# Amazon Linux 2023 VM
# ----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = "eastus2"
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  # ---- PLAN BLOCK REQUIRED FOR MARKETPLACE IMAGE ----
  plan {
    name      = var.vm_sku
    publisher = var.vm_publisher
    product   = var.vm_offer
  }
}

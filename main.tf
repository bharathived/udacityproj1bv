# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
subscription_id = "{{env `ARM_SUBSCRIPTION_ID`}}"
client_id       = "{{env `ARM_CLIENT_ID`}}"
client_secret   = "{{env `ARM_CLIENT_SECRET`}}"
tenant_id       = "{{env `ARM_TENANT_ID`}}"

features {}
}

data "azurerm_resource_group" "main" {
  name     = "udacity-proj1-rg"
}

output "id" {
  value = data.azurerm_resource_group.main.id
}

# Locate the existing custom image
data "azurerm_image" "main" {
  name                = "myPackerImage-0.0.1"
  resource_group_name = "udacity-proj1-rg"
}

output "image_id" {
  value = "/subscriptions/7830d897-be2f-47e8-826c-fc38b4760138/resourceGroups/udacity-proj1-rg/providers/Microsoft.Compute/images/myPackerImage-0.0.1"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
      name ="udacity"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-secgrp"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

 security_rule {
    name                          = "udacityproject1"
    priority                     =  100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    destination_address_prefix   = "*"
  }

  tags = {
      name ="udacity"
  }
}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
      name ="udacity"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pubip1"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags = {
      environment ="prod",
      name = "udacity"
  }

}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = "${var.tags}"
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "main" {

  loadbalancer_id     = azurerm_lb.main.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.main.id
}


resource "azurerm_virtual_machine_scale_set" "main" {
  name                = "${var.prefix}-vmscaleset"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = "${var.instance_count}"
  }

  storage_profile_image_reference {
    id = "${data.azurerm_image.main.id}"
  }

  storage_profile_os_disk {
    name              = "vmss"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = "${var.admin_user}"
    admin_password       = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  tags = "${var.tags}"
}






# Create a new Virtual Machine based on the custom Image
resource "azurerm_virtual_machine" "main" {
  name                             = "${var.prefix}-vm"
  location                         = data.azurerm_resource_group.main.location
  resource_group_name              = data.azurerm_resource_group.main.name
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_D2s_v3"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.main.id}"
  }
  storage_os_disk {
    name              = "myVM2-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

os_profile {
  computer_name  = "APPVM"
  admin_username = "${var.username}"
  admin_password = "${var.password}"
}

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Production"
  }

}

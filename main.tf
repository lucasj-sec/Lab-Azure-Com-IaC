terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

#provedor
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

#Resource Group
resource "azurerm_resource_group" "lab" {
  name     = "rg-laboratorio-01"
  location = var.location
}

#VNET
resource "azurerm_virtual_network" "lab_vnet" {
  name                = "vnet-laboratorio"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

#SUBNET
resource "azurerm_subnet" "subnet" {
  name                 = "snet-laboratorio"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#placa de rede
resource "azurerm_network_interface" "nic" {
  name                = "nic_laboratorio"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "ip-interno"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

#Solicitar Ip Na Azure
resource "azurerm_public_ip" "public_ip" {
  name                = "ip-publico-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-laboratorio"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-ubuntu-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  custom_data         = filebase64("setup.sh")

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

#OutPuts
output "ip_da_maquina" {
  value = azurerm_public_ip.public_ip.ip_address
}
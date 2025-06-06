provider "azurerm" {
  features {}
 subscription_id      = ""
 client_id            = ""
 client_secret        = ""
 tenant_id            = ""
 
}

# 1 Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroupname
  location = var.resourcelaocation
}

# 2 Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
 name                = var.vnetname
 address_space       = var.addressspace
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
}


# 3 Create a subnet
resource azurerm_subnet "sub" {
  name                 = var.subnetname
  address_prefixes     = var.addressprefix
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name 
  }
  
# 4 Create Public IP code 
resource "azurerm_public_ip" "pip" {
  name                = var.publicipname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# 5 Create NIC or Network interface 
resource "azurerm_network_interface" "nic" {
  name                = var.nicname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"

#Reference to a Public IP Address to associate with this NIC
public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Search for “terraform azure NSG subnet association” in google
# 6 create NSG and NSG association 
 resource "azurerm_network_security_group" "nsg" {
  name                = var.nsgname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.sub.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg]
}

# 7 create Linux virtual machine 

resource "azurerm_linux_virtual_machine" "example" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_password = ""
  disable_password_authentication = false

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

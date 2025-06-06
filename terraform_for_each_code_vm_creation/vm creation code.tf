provider "azurerm" {
  features {}
 subscription_id      = "6091e541-38ca-48fc-90bc-7c8845aba00b"
 client_id            = "235172c9-1ac4-4b5a-a742-ad26683276d2"
 client_secret        = "X2W8Q~4QD648in-.HzpQVgZXnwSxyPkgFletbbvN"
 tenant_id            = "1c776527-2de6-471a-8a69-ada4ff3e9d98"

}

# 1 Create a resource group
resource "azurerm_resource_group" "rg" {
  for_each = var.resourcedetails

  name     = each.value.rg_name
  location = each.value.location
}


# 2 Create a virtual network within the resource group

resource "azurerm_virtual_network" "vnet" {
  for_each = var.resourcedetails

  name                = each.value.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
}


# 3 Create a subnet

resource "azurerm_subnet" "sub" {
  for_each = var.resourcedetails

  name                 = each.value.subnet_name
  address_prefixes     = ["10.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = azurerm_resource_group.rg[each.key].name
}

# 4 Create Public IP code 
resource "azurerm_public_ip" "pip" {
  for_each = var.resourcedetails

  name                = each.value.pip_name
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  allocation_method   = "Static"
}
  

# 5 Create NIC or Network interface 

resource "azurerm_network_interface" "nic" {
  for_each = var.resourcedetails

  name                = each.value.nic_name 
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.sub[each.key].id
    private_ip_address_allocation = "Dynamic"
  
#Reference to a Public IP Address to associate with this NIC
public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

# 6 create NSG and NSG association 
 resource "azurerm_network_security_group" "nsg" {
  for_each = var.resourcedetails

  name                = each.value.nsg_name
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

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
  for_each = var.resourcedetails

  subnet_id                 = azurerm_subnet.sub[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  depends_on = [azurerm_network_security_group.nsg]
}

# 7 create Linux virtual machine 

resource "azurerm_virtual_machine" "vm" {
  for_each = var.resourcedetails

  name                  = each.value.vm_name
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  vm_size               = each.value.vm_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${each.key}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = each.value.vm_name
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
}

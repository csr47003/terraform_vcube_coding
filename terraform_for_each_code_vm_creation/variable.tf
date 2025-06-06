variable "resourcedetails" {
  type = map(object({
    vm_name     = string
    location = string
    vm_size     = string
    rg_name  = string
    vnet_name = string
    subnet_name = string
    pip_name = string
    nsg_name = string
    nic_name = string
    
  }))

  default = {
    westus = {
      rg_name  = "westus-rg"  
      vm_name     = "west-vm"
      location = "westus2"
      vm_size     = "Standard_B2s"
      vnet_name = "west-vnet"
      subnet_name = "west-subnet"
      pip_name = "pip1"
      nsg_name = "ns1"
      nic_name = "nic1"
      

    }

    eastus = {
      rg_name  = "eastus-rg"  
      vm_name     = "east-vm"
      location = "eastus"
      vm_size     = "Standard_B1s"
      vnet_name = "east-vnet"
      subnet_name = "east-subnet"
      pip_name = "pip2"
      nsg_name = "nsg2"
      nic_name = "nic2"
      
     }
  }
}


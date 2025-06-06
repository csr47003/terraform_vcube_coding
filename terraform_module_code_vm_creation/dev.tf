

module "module_dev" {
    source = "./Module"
    resourcegroupname = "devrg"
    resourcelaocation = "eastus"
    vnetname = "devvnet"
    addressspace = ["10.10.0.0/16"]
    subnetname = "devsubnet"
    addressprefix = ["10.10.1.0/24"]
    publicipname = "devpip"
    nicname = "devnic"
    nsgname = "devnsg"
    vmname = "devvm"
}
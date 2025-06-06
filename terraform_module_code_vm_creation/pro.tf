

module "module_pro" {
    source = "./Module"
    resourcegroupname = "prorg"
    resourcelaocation = "westus"
    vnetname = "provnet"
    addressspace = ["10.20.0.0/16"]
    subnetname = "prosubnet"
    addressprefix = ["10.20.1.0/24"]
    publicipname = "propip"
    nicname = "pronic"
    nsgname = "pronsg"
    vmname = "provm"
}
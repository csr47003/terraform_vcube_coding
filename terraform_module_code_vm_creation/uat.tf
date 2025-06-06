

module "module_uat" {
    source = "./Module"
    resourcegroupname = "uatrg"
    resourcelaocation = "eastus"
    vnetname = "uatvnet"
    addressspace = ["10.30.0.0/16"]
    subnetname = "uatsubnet"
    addressprefix = ["10.30.1.0/24"]
    publicipname = "uatpip"
    nicname = "uatnic"
    nsgname = "uatnsg"
    vmname = "uatvm"
}
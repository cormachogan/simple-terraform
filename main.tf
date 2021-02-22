provider "vsphere" {
  user                 = "cloudadmin@vmc.local"
  password             = ""
  vsphere_server       = ""
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "SDDC-Datacenter"
}


resource "vsphere_folder" "folder" {
  path          = "your_user_name_terraform_folder"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

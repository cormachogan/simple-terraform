provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "VMware123!"
  vsphere_server       = "v10.27.51.106"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "OCTO-Datacenter"
}


resource "vsphere_folder" "folder" {
  path          = "terraform_folder"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

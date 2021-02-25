provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "******"
  vsphere_server       = "192.168.0.1"
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

resource "vsphere_tag_category" "user" {
    name        = "cormac"
    cardinality = "SINGLE"

    associable_types = [
        "VirtualMachine"
    ]
}
resource "vsphere_tag" "last_name" {
    name         = "hogan"
    category_id = vsphere_tag_category.user.id
}

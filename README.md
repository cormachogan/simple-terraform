# Terraform Hacknite - Lab1

## Introduction for the vSphere user

Terraform builds infrastructure based on code. For example, the following code would create a vSphere Tag Category.

```hcl
resource "vsphere_tag_category" "region" {
    name        = "region"
    cardinality = "SINGLE"

    associable_types = [
    "VirtualMachine"
    ]
}
```

To create a tag using the category above, you would use the following command:

```hcl
resource "vsphere_tag" "region" {
    name         = "UK"
    category_id = vsphere_tag_category.region.id
}
```

You can see how, by using `vsphere_tag_category.region.id`, we are referring to another resource created by Terraform.

One of the advantages about using Terraform is that it is able, in most cases, to work out dependencies between each resources. For example, in this instance, Terraform would create the Tag Category before creating the Tag.

If you want to deploy a resource in something that was not created by Terraform, you can use the data block.

Imagine you want to create a Folder in the Datacenter "SDDC-Datacenter". You would do the following.

```hcl
resource "vsphere_folder" "folder" {
path          = "terraform-test-folder"
type          = "vm"
datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datacenter" "dc" {
name = "SDDC-Datacenter" 
}
```

"Data" is simple a read-only API call to work out the ID of the DC in which we will deploy the folder.

Let's go and practice some of this. 

## LAB Time! ##

Go to the Terraform folder.

You will see a file called main.tf . This is the main Terraform configuration.

```hcl
provider "vsphere" {
user                 = var.vsphere_user
password             = var.vsphere_password
vsphere_server       = var.vsphere_server
allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
name = "SDDC-Datacenter"
}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

resource "vsphere_folder" "folder" {
path          = "your_user_name_terraform_folder"
type          = "vm"
datacenter_id = data.vsphere_datacenter.dc.id
}
```

Update the file with your user_name. The configuration above will create a folder.

Run the following commands:

`terraform init` to initialize the provider. Did you see "provider vsphere" in the configuration earlier? This tells Terraform to download a Terraform 'plugin' to let interact with vSphere. There are also providers for NSX-T, VMC, vRA, vCD, etc...
`terraform validate` to validate the syntax of your Terraform config file  
`terraform plan` to work out which resources Terraform will create, modify or delete on your behalf  
`terraform apply` to execute the plan.  


This is a very simple example. But imagine you add not just folders, but resources pools, clusters, tags, networks and security rules (using Terraform for NSX-T); you could define your entire VMware infrastructure as code. 

If you're enjoying Terraform and want to do something a bit more sophisticated, you could try to create vSphere tags and categories. Add this to your main.tf, run `terraform apply` and you will see that Terraform doesn't try to add another folder. Instead, it will just create the tag category and the tag.

```hcl
resource "vsphere_tag_category" "user" {
    name        = "your_user_name"
    cardinality = "SINGLE"

    associable_types = [
        "VirtualMachine"
    ]
}
resource "vsphere_tag" "last_name" {
    name         = "your_last_name"
    category_id = vsphere_tag_category.user.id
}
```

As you expand your code and your configuration, you can see how you could describe your entire infrastructure as code - not just compute but also security, networking, automation, cloud, migration, SD-WAN when you include providers for AWS, NSX, SD-WAN, HCX, vRA, etc.... 
You could then version it, repeat it, patch it, etc...

If you want to see a very advanced example, go through what Gilles and I did for VMworld:
https://github.com/gchek/VMworld2020

Finally: if you think that there is a provider missing for the product of your choice, let us know. 
Creating a provider is for advanced users as it required knowledge of the Go programming language but you know what? There are many Go programmers within VMware that can help you.

### Additional Resources

Official Terraform providers can be found [here](https://registry.terraform.io/namespaces/vmware).

Additional Terraform scripts and examples can be found on Nico's blog [here](https://nicovibert.com).

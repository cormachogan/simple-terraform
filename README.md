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

### Part 5 - APIs

PowerCLI and Terraform are very easy to use as you can see. But what PowerCLI and Terraform only do is making API calls under the hood.

You will find easier to understand automation by building some understanding of API architectures.

An API is an Application Programming Interface. Typically, a developer would create an API on an application or platform to enable a client to interact with it.

Most of the API requests follow the REST model on how communications with an API are executed (REST stands for Representation State Transfer).

Most common REST implementations use HTTP as the application protocol. 

Typically, API calls run a CRUD Action: Create, Read, Update or Delete.

For example:
- Create a VM
- Check the items of a content library
- Update the vSAN storage policy on a VM
- Remove a NSX network

Typically REST API requests are made through a HTTP verb, which would be:

- PUT   ===== CREATE
- GET   ===== READ
- PATCH  ==== UPDATE
- DELETE ==== DELETE

When you browse any page on the web, you just make a HTTP GET request to get the contents of a webpage.

It's the same if you want to get the contents of a vCenter, it will just be a GET call.

When you submit a form online, you just make a HTTP POST request to submit your details.

It's same when you want to create a network with NSX over the APIs: you just make a HTTP POST call, with the details about your network (subnet, mask, DHCP settings) in the body of the packet.

To leverage vSphere APIs, let's use cURL. Curl is a tool to make HTTP requests and will let us interact with the APIs directly.

Go back to your virtual desktop and open up the terminal.

The way it works with the vSphere APIs is that you need to get a temporary token in exchange for your vCenter credentials with a 

`POST https://{api_host}/rest/com/vmware/cis/session`

For example, on a Mac:

`curl -k -i -u $TF_VAR_vsphere_user:$TF_VAR_vsphere_password -X POST -c token.txt https://$TF_VAR_vsphere_server/rest/com/vmware/cis/session`

On a Windows machine, it would be:

`curl -k -i -u %TF_VAR_vsphere_user%:%TF_VAR_vsphere_password% -X POST -c token.txt https://%TF_VAR_vsphere_server%/rest/com/vmware/cis/session`

The output of the command would be something like this:

    {"value":"f3be0a4e-7fc8-48d8-b796-eb3c2f66970b"}

This temporary token above `f3be0a4e-7fc8-48d8-b796-eb3c2f66970b` can be used in subsequent API requests to authenticate against vCenter.

You can then use the value of the token to make an API call, for example, to get the list of folders in your environment (that will include the folders you created earlier):

On a Mac:

`curl -k -i -b token.txt https://$TF_VAR_vsphere_server/rest/vcenter/folder`

On a Windows machine:

`curl -k -i -b token.txt https://%TF_VAR_vsphere_server%/rest/vcenter/folder`


### Additional Resources

PowerCLI resources can be found [here](https://developer.vmware.com/powercli).

Official Terraform providers can be found [here](https://registry.terraform.io/namespaces/vmware).

Additional Terraform scripts and examples can be found on Nico's blog [here](https://nicovibert.com).

The Curl script used above was found [here](https://www.stevetrefethen.com/accessing-vmware-vcenter-rest-api-authentication-from-curl/).


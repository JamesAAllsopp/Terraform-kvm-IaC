# Terraform KVM scripts

The purpose of this is to move more of what I set up to use IaC rather than set everything up manually each time

You need to set things up to work with v0.13 to get these scripts working. See [here](https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/docs/migration-13.md)  

There are still two problems remaining:
+ I've not got passwords working properly with cloud-init
+ Bridge networking only works (it gets an IP, but the hostname isn't up) if the networking in systemd is restarted
  after boot, but this shows up as a state deviation in terraform.
  
## BasicAlmaLinuxScript

This works and sets things up properly. It uses cloud init. Just get it to work with 

+ terraform plan
+ terraform apply

Then terraform destroy to finish. 

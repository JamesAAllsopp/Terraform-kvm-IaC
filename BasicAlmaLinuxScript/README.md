# Terraform based off an example image

ssh -i ~/.ssh/id_kvm_ed25519 james@192.168.122.252      

passcode is in pass for that key.
I don't believe I've ever got the password working.



This to test changing the pool away from default. Default is /var/lib/... but I'd prefer something like the ZFS pool
where there's loads of space and snapshots

Note that dhcp and dns doesn't work, you have to look in the virt-manager to find the ip

Current plan

Done - Changed name to match
Done - Change pool location
Change network to use VirtBridge.
Change to use Rocky
install Puppet

create a second machine
Fix password

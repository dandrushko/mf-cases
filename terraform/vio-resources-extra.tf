#Group3 resources
#VMs Groups3 will be attached to Net2 created in runtime
resource "openstack_compute_instance_v2" "Group3-VM" {
  count = "${var.instance_number}"
  name      = "${format("Group3-VM-%d", count.index+1)}"
  image_id  = "c70de188-7b03-42de-bbb6-10e228e490a0"
  flavor_id = "2"
  key_pair  = "megafon"

  network {
    port = "${element(openstack_networking_port_v2.group3.*.id, count.index)}"
  }
}

resource "openstack_networking_port_v2" "group3" {
  count = "${var.instance_number}"
  name = "port-group3vm-${count.index}"
  network_id = "${openstack_networking_network_v2.net2.id}"
  admin_state_up = true
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_2.id}"
  }
}

resource "openstack_networking_floatingip_v2" "FIPs_Group3" {
  count = "${var.instance_number}"
  pool = "${var.external_network}"
}

resource "openstack_compute_floatingip_associate_v2" "FIPs_Group3_bind" {
  count = "${var.instance_number}"
  floating_ip = "${element(openstack_networking_floatingip_v2.FIPs_Group3.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.Group3-VM.*.id, count.index)}"
}
### End of the Group3 resources


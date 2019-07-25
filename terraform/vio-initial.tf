variable "instance_number" {
  default = "10"
}

provider "openstack" {
  user_name   = "${var.username}"
  tenant_id   = "${var.project_id}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
  region      = "${var.region}"
  insecure    = "${var.insecure}"
}


# VMs Group1 attached to existing network #1
resource "openstack_compute_instance_v2" "Group1-VM" {
  count = "${var.instance_number}"
  name      = "${format("Group1-VM-%d", count.index+1)}"
  image_id  = "c70de188-7b03-42de-bbb6-10e228e490a0"
  flavor_id = "2"
  key_pair  = "megafon"

  network {
    uuid = "${var.net_1}"
  }
}

# VMs Group2 attached to existing network #1 and to Net2 created in runtime
resource "openstack_compute_instance_v2" "Group2-VM" {
  count = "${var.instance_number}"
  name      = "${format("Group2-VM-%d", count.index+1)}"
  image_id  = "c70de188-7b03-42de-bbb6-10e228e490a0"
  flavor_id = "2"
  key_pair  = "megafon"

  network {
    uuid = "${var.net_1}"
  }

  network {
    port = "${element(openstack_networking_port_v2.group2.*.id, count.index)}"
  }
}

resource "openstack_networking_port_v2" "group2" {
  count = "${var.instance_number}"
  name = "port-group2vm-${count.index}"
  network_id = "${openstack_networking_network_v2.net2.id}"
  admin_state_up = true
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_2.id}"
  }
}

resource "openstack_networking_network_v2" "net2" {
  name = "Megafon-NET2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_2"{
  name       = "subnet_2"
  network_id = "${openstack_networking_network_v2.net2.id}"
  cidr       = "192.168.211.0/24"
  ip_version = 4
  gateway_ip  = "192.168.211.1"
  enable_dhcp = "true"
  allocation_pool {
    start = "192.168.211.10"
    end   = "192.168.211.100"
  }
}

resource "openstack_networking_router_interface_v2" "router_interface_net2" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_2.id}"
}

resource "openstack_networking_floatingip_v2" "FIPs_Group1" {
  count = "${var.instance_number}"
  pool = "${var.external_network}"
}

resource "openstack_compute_floatingip_associate_v2" "FIPs_Group1_bind" {
  count = "${var.instance_number}"
  floating_ip = "${element(openstack_networking_floatingip_v2.FIPs_Group1.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.Group1-VM.*.id, count.index)}"
}


resource "openstack_networking_floatingip_v2" "FIPs_Group2" {
  count = "${var.instance_number}"
  pool = "${var.external_network}"
}

resource "openstack_compute_floatingip_associate_v2" "FIPs_Group2_bind" {
  count = "${var.instance_number}"
  floating_ip = "${element(openstack_networking_floatingip_v2.FIPs_Group2.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.Group2-VM.*.id, count.index)}"
}


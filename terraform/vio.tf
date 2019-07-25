provider "openstack" {
  user_name   = "admin"
  tenant_id   = "23c3ca912fd546f8afa7760017768c26"
  password    = "VMware1!"
  auth_url    = "https://192.168.121.225:5000/v3"
  region      = "nova"
  insecure    = "1"
}

# Create a web server
resource "openstack_compute_instance_v2" "megafon-instance" {
  name      = "megafon-instance"
  image_id  = "c70de188-7b03-42de-bbb6-10e228e490a0"
  flavor_id = "2"
  key_pair  = "megafon"

  network {
    uuid = "68b74c66-5f33-458e-8fce-073f84d1ddd6"
  }

}


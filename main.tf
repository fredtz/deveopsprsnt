provider "digitalocean" {
    token = "insert your token here"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Demo"
  public_key = "${file("/Users/user/terraform-demo/.ssh/id_rsa.pub")}"
}

# Create a new tag
resource "digitalocean_tag" "mytag" {
  name = "nginx-server"
}

# Create a new droplet in ams3 with the tag
resource "digitalocean_droplet" "web-1" {
    name = "web1"
    image = "ubuntu-16-04-x64"
    size = "s-1vcpu-1gb"
    region = "ams3"
    ipv6 = true
    private_networking = false
    tags   = ["${digitalocean_tag.mytag.id}"]
    ssh_keys = ["a3:85:3d:2a:51:c6:14:55:da:ba:4a:1d:54:d4:96:75"]
}

# Create a new tag
resource "digitalocean_tag" "mytag2" {
  name = "web-server"
}

resource "digitalocean_droplet" "web-server2" {
    name = "web-server2"
    image = "ubuntu-16-04-x64"
    size = "s-1vcpu-1gb"
    region = "ams3"
    ipv6 = true
    private_networking = false
    ssh_keys = ["a3:85:3d:2a:51:c6:14:55:da:ba:4a:1d:54:d4:96:75"]
}


resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer-1"
  region = "ams3"
  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

droplet_ids = ["${digitalocean_droplet.web-1.id}","${digitalocean_droplet.web-server2.id}"]
}

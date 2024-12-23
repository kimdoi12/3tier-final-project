# Google provider configuration
provider "google" {
    credentials = file("kg-final-project-1b66ab4e796d.json")
    project     = "kg-final-project"
    region      = "asia-northeast3"
}

# GCP compute network
resource "google_compute_network" "vpc_network" {
    name                    = "gcp-vpc"
    auto_create_subnetworks = false
    routing_mode            = "GLOBAL"
}

# GCP subnetwork
resource "google_compute_subnetwork" "gcp-subnet" {
    name           = "gcp-vpc-pub"
    ip_cidr_range  = "192.168.0.0/24"
    region         = "asia-northeast3"
    network        = google_compute_network.vpc_network.id
}

#GCP compute firewall
resource "google_compute_firewall" "allow-internal" {
    name = "icmp-test"
    network = google_compute_network.vpc_network.id
    allow {
        protocol = "icmp"
    }
    source_ranges = [
        "0.0.0.0/0"
    ]
}

resource "google_compute_firewall" "allow-http" {
    name = "http-test"
    network = google_compute_network.vpc_network.id
    allow {
        protocol = "tcp"
        ports    = ["80"]
    }
    source_ranges = [
        "0.0.0.0/0"
    ]
    target_tags = ["http"]
}

resource "google_compute_firewall" "allow-https" {
    name = "https-test"
    network = google_compute_network.vpc_network.id
    allow {
        protocol = "tcp"
        ports    = ["443"]
    }
    source_ranges = [
        "0.0.0.0/0"
    ]
    target_tags = ["https"]
}

resource "google_compute_firewall" "allow-ssh" {
    name = "ssh-test"
    network = google_compute_network.vpc_network.id
    allow {
        protocol = "tcp"
        ports    = ["22"]
    }
    source_ranges = [
        "0.0.0.0/0"
    ]
    target_tags = ["ssh"]
}

#GCP VPN RESOURCES
resource "google_compute_router" "router" {
  name = "ha-vpn-router"
  network = google_compute_network.vpc_network.id
  bgp {
    asn = 65000
  }
}

resource "google_container_cluster" "nginx-cluster" {
  name = "nginx-cluster"
  location = "asia-northeast3"
  initial_node_count = 1
  network = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.gcp-subnet.id
  enable_autopilot = true
  deletion_protection = false
}

resource "google_compute_ha_vpn_gateway" "ha-gateway" {
  name = "ha-vpn"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_external_vpn_gateway" "peer-gw" {
  name = "peer-gw"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  interface {
    id = 0
    ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel1_address
  }
  interface {
    id = 1
    ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel2_address
  }
  interface {
    id = 2
    ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel1_address
  }
  interface {
    id = 3
    ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel2_address
  }
}


resource "google_compute_vpn_tunnel" "tunnel1" {
  name = "ha-vpn-tunnel1"
  vpn_gateway = google_compute_ha_vpn_gateway.ha-gateway.id
  peer_external_gateway = google_compute_external_vpn_gateway.peer-gw.id
  peer_external_gateway_interface = 0
  shared_secret = aws_vpn_connection.aws-gcp-vpn-0.tunnel1_preshared_key
  router = google_compute_router.router.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name = "ha-vpn-tunnel2"
  vpn_gateway = google_compute_ha_vpn_gateway.ha-gateway.id
  peer_external_gateway = google_compute_external_vpn_gateway.peer-gw.id
  peer_external_gateway_interface = 1
  shared_secret = aws_vpn_connection.aws-gcp-vpn-0.tunnel2_preshared_key
  router = "${google_compute_router.router.id}"
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel3" {
  name = "ha-vpn-tunnel3"
  vpn_gateway = google_compute_ha_vpn_gateway.ha-gateway.id
  peer_external_gateway = google_compute_external_vpn_gateway.peer-gw.id
  peer_external_gateway_interface = 2
  shared_secret = aws_vpn_connection.aws-gcp-vpn-1.tunnel1_preshared_key
  router = "${google_compute_router.router.id}"
  vpn_gateway_interface = 1
}

resource "google_compute_vpn_tunnel" "tunnel4" {
  name = "ha-vpn-tunnel4"
  vpn_gateway = google_compute_ha_vpn_gateway.ha-gateway.id
  peer_external_gateway = google_compute_external_vpn_gateway.peer-gw.id
  peer_external_gateway_interface = 3
  shared_secret = aws_vpn_connection.aws-gcp-vpn-1.tunnel2_preshared_key
  router = "${google_compute_router.router.id}"
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "router-interface1" {
  name = "router-interface1"
  router = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "route-peer1" {
  name = "route-peer1"
  router = google_compute_router.router.name
  ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel1_cgw_inside_address
  peer_ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel1_vgw_inside_address
  peer_asn = 64512
  interface = google_compute_router_interface.router-interface1.name
}

resource "google_compute_router_interface" "router-interface2" {
  name = "router-interface2"
  router = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "route-peer2" {
  name = "route-peer2"
  router = google_compute_router.router.name
  ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel2_cgw_inside_address
  peer_ip_address = aws_vpn_connection.aws-gcp-vpn-0.tunnel2_vgw_inside_address
  peer_asn = 64512
  interface = google_compute_router_interface.router-interface2.name
}

resource "google_compute_router_interface" "router-interface3" {
  name = "route-interface3"
  router = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name
}

resource "google_compute_router_peer" "route-peer3" {
  name = "route-peer3"
  router = google_compute_router.router.name
  ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel1_cgw_inside_address
  peer_ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel1_vgw_inside_address
  peer_asn = 64512
  interface = google_compute_router_interface.router-interface3.name
}

resource "google_compute_router_interface" "router-interface4" {
  name = "route-interface4"
  router = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name
}

resource "google_compute_router_peer" "route-peer4" {
  name = "route-peer4"
  router = google_compute_router.router.name
  ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel2_cgw_inside_address
  peer_ip_address = aws_vpn_connection.aws-gcp-vpn-1.tunnel2_vgw_inside_address
  peer_asn = 64512
  interface = google_compute_router_interface.router-interface4.name
}

resource "google_dns_managed_zone" "fruits" {
  name = "fruits"
  dns_name = "doiaws.shop."
  dnssec_config {
    state = "on"
  }
}
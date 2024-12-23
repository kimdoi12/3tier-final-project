#VPN RESOURCES

resource "aws_customer_gateway" "cgw-for-gcp-0" {
    bgp_asn = 65000
    ip_address = google_compute_ha_vpn_gateway.ha-gateway.vpn_interfaces.0.ip_address
    type = "ipsec.1"
    tags = {
      Name = "cgw-for-gcp-0"
    }
}

resource "aws_customer_gateway" "cgw-for-gcp-1" {
    bgp_asn = 65000
    ip_address = google_compute_ha_vpn_gateway.ha-gateway.vpn_interfaces.1.ip_address
    type = "ipsec.1"
    tags = {
      Name = "cgw-for-gcp-1"
    }
}

resource "aws_vpn_gateway" "vgw-for-gcp" {
    vpc_id = aws_vpc.SEC-PRD-VPC.id

    tags = {
        Name = "vgw-for-gcp"
    }
}

resource "aws_vpn_gateway_route_propagation" "testing_route" {
  route_table_id = aws_route_table.SEC-PRD-RT-PUB.id
  vpn_gateway_id = aws_vpn_gateway.vgw-for-gcp.id
}

resource "aws_vpn_gateway_route_propagation" "testing_route1" {
    route_table_id = aws_route_table.SEC-PRD-RT-PRI-2A.id
    vpn_gateway_id = aws_vpn_gateway.vgw-for-gcp.id
}

resource "aws_vpn_gateway_route_propagation" "testing_route2" {
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2C.id
  vpn_gateway_id = aws_vpn_gateway.vgw-for-gcp.id
}

resource "aws_vpn_connection" "aws-gcp-vpn-0" {
    vpn_gateway_id = aws_vpn_gateway.vgw-for-gcp.id
    customer_gateway_id = aws_customer_gateway.cgw-for-gcp-0.id
    type = "ipsec.1"
    static_routes_only = false
    local_ipv4_network_cidr = "10.10.20.0/24"
    remote_ipv4_network_cidr = "192.168.0.0/24"
    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev2"]
    tags = {
        Name = "aws-gcp-vpn-0"
    }
}

resource "aws_vpn_connection" "aws-gcp-vpn-1" {
    vpn_gateway_id = aws_vpn_gateway.vgw-for-gcp.id
    customer_gateway_id = aws_customer_gateway.cgw-for-gcp-1.id
    type = "ipsec.1"
    static_routes_only = false
    local_ipv4_network_cidr = "10.10.120.0/24"
    remote_ipv4_network_cidr = "192.168.0.0/24"
    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev2"]
    tags = {
        Name = "aws-gcp-vpn-1"
    }
}
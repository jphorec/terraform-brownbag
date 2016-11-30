variable "vm_name" {
    default = "brownbag-concourse-vm"
}
variable "location" {
    default = "Central US"
}
variable "resource_group_name" {
    default = "Brownbag"
}
variable "network_interface_ids" {
    default = ""
}
variable "vm_size" {
    default = "Standard_A0"
}
variable "image_publisher" {
    default = "Canonical"
}
variable "image_offer" {
    default = "UbuntuServer"
}
variable "image_sku" {
    default = "14.04.2-LTS"
}
variable "image_version" {
    default = "latest"
}
variable "os_disk_name" {
    default = "concoursedisk"
}
variable "os_disk_vhd" {
    default = ""
}
variable "os_disk_caching" {
    default = "ReadWrite"
}
variable "os_disk_create_option" {
    default = "FromImage"
}
variable "os_profile_name" {
    default = ""
}
variable "os_profile_user" {
    default = "jhorecny"
}
variable "os_profile_pw" {
    default = "Pa22w0rd1234"
}
variable "os_linux_config" {
    default = "false"
}
variable "storage_location" {
    default = "centralus"
}
variable "storage_account_name" {
    default = "concoursebrownbag"
}
variable "storage_account_type" {
    default = "Standard_LRS"
}
variable "storage_container_name" {
    default = "brownbag-vhds"
}
variable "storage_container_access" {
    default = "private"
}
variable "virtual_network_name" {
    default = "brownbag-virtualnetwork"
}
variable "address_space" {
    default = "10.0.0.0/16"
}
variable "subnet_name" {
    default = "brownbag-subnet"
}
variable "subnet_address_prefix" {
    default = "10.0.2.0/24"
}
variable "public_ip_name" {
    default = "brownbag-publicip"
}
variable "public_ip_allocation" {
    default = "static"
}
variable "domain_name_label" {
    default = "concourse-brownbag"
}
variable "network_interface_name" {
    default = "brownbag-network-interface"
}
variable "ipconfig_name" {
    default = "testconfiguration1"
}
variable "private_ip_allocation" {
    default = "dynamic"
}

variable "http_name" {default = "HTTP"}
variable "http_priority" {default = 200}
variable "http_direction" {default = "Inbound"}
variable "http_access" { default = "Allow"}
variable "http_protocol" { default = "TCP"}
variable "http_source_port_range" {default = "*"}
variable "http_destination_port_range" { default = "80"}
variable "http_source_address_prefix" { default = "*"}
variable "http_destination_address_prefix" { default = "*"}
variable "network_security_group_name" { default = "brownbag-security-group"}

variable "https_name" {default = "HTTPS"}
variable "https_priority" {default  = 300}
variable "https_direction" { default = "Inbound"}
variable "https_access"{ default = "Allow"}
variable "https_protocol"{ default = "Tcp"}
variable "https_source_port_range" {default = "*"}
variable "https_destination_port_range"{ default = "443"}
variable "https_source_address_prefix" {default = "*"}
variable "https_destination_address_prefix" {default = "*"}

variable "ssh_name" { default = "SSH"}
variable "ssh_priority" {default = 100}
variable "ssh_direction" {default = "Inbound"}
variable "ssh_access" {default = "Allow"}
variable "ssh_protocol" {default = "Tcp"}
variable "ssh_source_port_range" {default = "22"}
variable "ssh_destination_port_range" {default = "22"}
variable "ssh_source_address_prefix" {default = "Internet"}
variable "ssh_destination_address_prefix" {default = "*"}

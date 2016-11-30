
resource "azurerm_virtual_network" "test" {
    name = "${var.virtual_network_name}"
    address_space = ["${var.address_space}"]
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_subnet" "test" {
    name = "${var.subnet_name}"
    resource_group_name = "${var.resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.test.name}"
    address_prefix = "${var.subnet_address_prefix}"
}

resource "azurerm_public_ip" "test" {
    name = "${var.public_ip_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    public_ip_address_allocation = "${var.public_ip_allocation}"
    domain_name_label = "${var.domain_name_label}"
}

resource "azurerm_network_interface" "test" {
    name = "${var.network_interface_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    //network_security_group_id = "${var.security_group}"

    ip_configuration {
        name = "${var.ipconfig_name}"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "${var.private_ip_allocation}"
        public_ip_address_id = "${azurerm_public_ip.test.id}"
    }
}

output "network_interface_id" {
    value = "${azurerm_network_interface.test.id}"
}

resource "azurerm_network_security_group" "test" {
    name = "${var.name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
}

output "name" {
    value = "${azurerm_network_security_group.test.name}"
}

output "id" {
    value = "${azurerm_network_security_group.test.id}"
}

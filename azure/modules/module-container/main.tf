resource "azurerm_storage_container" "test" {
    name = "${var.name}"
    resource_group_name = "${var.resource_group_name}"
    storage_account_name = "${var.storage_account_name}"
    container_access_type = "${var.storage_container_access}"
}

output "name" {
    value = "${azurerm_storage_container.test.name}"
}

resource "azurerm_storage_account" "test" {
    name = "${var.storage_account_name}"
    resource_group_name = "${var.resource_group_name}"
    location = "${var.storage_location}"
    account_type = "${var.storage_account_type}"

    tags {
        environment = "playground"
    }
}

output "name" {
    value = "${azurerm_storage_account.test.name}"
}
output "endpoint" {
    value = "${azurerm_storage_account.test.primary_blob_endpoint}"
}

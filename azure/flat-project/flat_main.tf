# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "d0d6e3ce-fd48-4617-90d2-11d4f2a7b5aa"
  client_id       = "81a9e3f6-f53d-4802-b3a0-88b9e57139af"
  client_secret   = "7Yy6ut3QrbyxWIEfaZfBPqdJq9q3fVo9yf3M0E/bAGA="
  tenant_id       = "6e7a7880-46d9-4297-83f4-7cce96b40442"
}

resource "azurerm_resource_group" "test" {
    name = "brownbag-demo"
    location = "Central US"
}

resource "azurerm_virtual_network" "test" {
    name = "brownbag-virtualnetwork"
    address_space = ["10.0.0.0/16"]
    location = "Central US"
    resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
    name = "brownbag-subnet"
    resource_group_name = "${azurerm_resource_group.test.name}"
    virtual_network_name = "${azurerm_virtual_network.test.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
    name = "brownbag-publicip"
    location = "Central US"
    resource_group_name = "${azurerm_resource_group.test.name}"
    public_ip_address_allocation = "static"
    domain_name_label = "concourse-brownbag"
}

resource "azurerm_network_interface" "test" {
    name = "brownbag-network-interface"
    location = "Central US"
    resource_group_name = "${azurerm_resource_group.test.name}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.test.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.test.id}"
    }
}

resource "azurerm_storage_account" "test" {
    name = "brownbagstorage"
    resource_group_name = "${azurerm_resource_group.test.name}"
    location = "centralus"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

resource "azurerm_storage_container" "test" {
    name = "brownbag-vhds"
    resource_group_name = "${azurerm_resource_group.test.name}"
    storage_account_name = "${azurerm_storage_account.test.name}"
    container_access_type = "private"
}

resource "azurerm_virtual_machine" "test" {
    name = "brownbag-concourse-vm"
    location = "Central US"
    resource_group_name = "${azurerm_resource_group.test.name}"
    network_interface_ids = ["${azurerm_network_interface.test.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk1"
        vhd_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "hostname"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "staging"
    }
}

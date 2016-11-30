# Configure the Microsoft Azure Provider

resource "azurerm_virtual_machine" "test" {
    name = "${var.vm_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    network_interface_ids = ["${var.network_interface_ids}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.image_publisher}"
        offer = "${var.image_offer}"
        sku = "${var.image_sku}"
        version = "${var.image_version}"
    }

    storage_os_disk {
        name = "${var.os_disk_name}"
        vhd_uri = "${var.os_disk_vhd}"
        caching = "${var.os_disk_caching}"
        create_option = "${var.os_disk_create_option}"
    }

    os_profile {
        computer_name = "${var.os_profile_name}"
        admin_username = "${var.os_profile_user}"
        admin_password = "${var.os_profile_pw}"
    }

    os_profile_linux_config {
        disable_password_authentication = "${var.os_linux_config}"
    }

    /*provisioner "file" {
        source = "${var.source_file}"
        destination = "${var.destination}"
        connection {
            type = "ssh"
            user = "${var.os_profile_user}"
            password = "${var.os_profile_pw}"
        }
    }*/
}

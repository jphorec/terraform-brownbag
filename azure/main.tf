provider "azurerm" {

}

module "resourcegroup" {
  source = "modules/module-resourcegroup"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
}

module "security_group" {
  source = "modules/module-security"
  name = "${var.network_security_group_name}"
  location = "${var.location}"
  resource_group_name = "${module.resourcegroup.name}"
}

module "http_security_rule" {
  source = "modules/module-security-rule"
  name = "${var.http_name}"
  priority = "${var.http_priority}"
  direction = "${var.http_direction}"
  access = "${var.http_access}"
  protocol = "${var.http_protocol}"
  source_port_range = "${var.http_source_port_range}"
  destination_port_range = "${var.http_destination_port_range}"
  source_address_prefix = "${var.http_source_address_prefix}"
  destination_address_prefix = "${var.http_destination_address_prefix}"
  resource_group_name = "${module.resourcegroup.name}"
  network_security_group_name = "${module.security_group.name}"
}
module "https_security_rule" {
  source = "modules/module-security-rule"
  name = "${var.https_name}"
  priority = "${var.https_priority}"
  direction = "${var.https_direction}"
  access = "${var.https_access}"
  protocol = "${var.https_protocol}"
  source_port_range = "${var.https_source_port_range}"
  destination_port_range = "${var.https_destination_port_range}"
  source_address_prefix = "${var.https_source_address_prefix}"
  destination_address_prefix = "${var.https_destination_address_prefix}"
  resource_group_name = "${module.resourcegroup.name}"
  network_security_group_name = "${module.security_group.name}"
}
module "ssh_security_rule" {
  source = "modules/module-security-rule"
  name = "${var.ssh_name}"
  priority = "${var.ssh_priority}"
  direction = "${var.ssh_direction}"
  access = "${var.ssh_access}"
  protocol = "${var.ssh_protocol}"
  source_port_range = "${var.ssh_source_port_range}"
  destination_port_range = "${var.ssh_destination_port_range}"
  source_address_prefix = "${var.ssh_source_address_prefix}"
  destination_address_prefix = "${var.ssh_destination_address_prefix}"
  resource_group_name = "${module.resourcegroup.name}"
  network_security_group_name = "${module.security_group.name}"
}
module "network" {
  source = "modules/module-network"
  location = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  address_space = "${var.address_space}"
  resource_group_name = "${module.resourcegroup.name}"
  subnet_name = "${var.subnet_name}"
  subnet_address_prefix = "${var.subnet_address_prefix}"
  public_ip_name = "${var.public_ip_name}"
  public_ip_allocation = "${var.public_ip_allocation}"
  domain_name_label = "${var.domain_name_label}"
  network_interface_name = "${var.network_interface_name}"
  ipconfig_name = "${var.ipconfig_name}"
  private_ip_allocation = "${var.private_ip_allocation}"
  security_group = "${module.security_group.id}"
}

module "storage_account" {
  source = "modules/module-storage"
  storage_location = "${var.storage_location}"
  storage_account_name = "${var.storage_account_name}"
  resource_group_name = "${module.resourcegroup.name}"
  storage_account_type = "${var.storage_account_type}"
}

module "storage_container" {
  source = "modules/module-container"
  resource_group_name = "${module.resourcegroup.name}"
  storage_account_name = "${module.storage_account.name}"
  name = "${var.storage_container_name}"
  storage_container_access = "${var.storage_container_access}"
}

module "module-vm" {
  source = "modules/module-vm"
  vm_name = "${var.vm_name}"
  location = "${var.location}"
  resource_group_name = "${module.resourcegroup.name}"
  network_interface_ids = "${module.network.network_interface_id}"
  vm_size = "${var.vm_size}"
  image_publisher = "${var.image_publisher}"
  image_offer = "${var.image_offer}"
  image_sku = "${var.image_sku}"
  image_version = "${var.image_version}"
  os_disk_name = "${var.os_disk_name}"
  os_disk_vhd = "${module.storage_account.endpoint}${module.storage_container.name}/${var.os_disk_name}.vhd"
  os_disk_caching = "${var.os_disk_caching}"
  os_disk_create_option = "${var.os_disk_create_option}"
  os_profile_name = "${var.domain_name_label}"
  os_profile_user = "${var.os_profile_user}"
  os_profile_pw = "${var.os_profile_pw}"
  os_linux_config = "${var.os_linux_config}"
  source = "concourse-docker.yml"
  destination = "etc/concourse-docker.yml"
}

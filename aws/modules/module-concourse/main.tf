variable "name" {}
variable "route53_zone" {}
variable "route53_name" {}
variable "route53_type" {}
variable "instance_type" {}
variable "public_key_name" {}
variable "public_key_path" {}

module "vpc" {
    source = "../module-vpc"
    name = "${var.name}"
}

module "alb" {
    source = "../module-alb"
    name = "${var.name}"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_ids = ["${module.vpc.subnet_ids}"]
}

module "dns" {
    source = "../module-route53"
    route53_zone_id = "${var.route53_zone}"
    route53_name = "${var.route53_name}"
    route53_type = "${var.route53_type}"
    route53_alias_name = "${module.alb.alb_dns}"
    alias_zone_id = "${module.alb.zone_id}"
}

module "ec2_instance" {
    source = "../module-ec2"
    name = "${var.name}"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.subnet_id}"
    alb_id = "${module.alb.alb_id}"
    concourse_target_arn = "${module.alb.concourse_target_arn}"
    nginx_target_arn = "${module.alb.nginx_target_arn}"
    instance_type = "${var.instance_type}"
    public_key_name = "${var.public_key_name}"
    public_key_path = "${var.public_key_path}"
}
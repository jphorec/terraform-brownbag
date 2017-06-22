variable route53_zone_id {}
variable route53_name {}
variable route53_type {}
variable route53_alias_name {}
variable alias_zone_id {}
variable eval_target_health { default = true }

resource "aws_route53_record" "www" {
   zone_id = "${var.route53_zone_id}"  #"*********"
   name = "${var.route53_name}"      #"joshhorecny.com"
   type = "${var.route53_type}" #"A"
   alias {
     name = "${var.route53_alias_name}" #"${aws_alb.main.dns_name}"
     zone_id = "${var.alias_zone_id}"  #"${aws_alb.main.zone_id}"
     evaluate_target_health = "${var.eval_target_health}"
   }
}
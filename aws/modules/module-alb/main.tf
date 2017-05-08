variable vpc_id {}
variable name {}
variable subnet_ids {
  type = "list"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "alb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "main" {
  name            = "tf-example-alb-ecs"
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.alb.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.concourse-target-grp.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "nginx" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nginx-target-grp.id}"
    type             = "forward"
  }
}
resource "aws_alb_listener_rule" "concourse" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.concourse-target-grp.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/concourse/*"]
  }
}

resource "aws_alb_target_group" "concourse-target-grp" {
  name     = "brownbag-target-grp"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_target_group" "nginx-target-grp" {
  name     = "nginx-target-grp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

output "concourse_target_arn" {
    value = "${aws_alb_target_group.concourse-target-grp.arn}"
}
output "nginx_target_arn" {
    value = "${aws_alb_target_group.nginx-target-grp.id}"
}
output "alb_id" {
    value = "${aws_security_group.alb.id}"
}
output "alb_dns" {
    value = "${aws_alb.main.dns_name}"
}
output "zone_id" {
    value = "${aws_alb.main.zone_id}"
}
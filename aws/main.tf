provider "aws" {
  region     = "us-east-1"
}

#resource "aws_s3_bucket" "b" {
#    bucket = "brownbag-bucket"
#    acl = "private"

#    tags {
#        Name = "Brownbag"
#        Environment = "Demo"
#    }
#}

# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#   }
#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical
# }

variable az_count { default = 2}
# Create a VPC to launch our instances into
resource "aws_vpc" "brownbag_vpc" {
  cidr_block = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {}
resource "aws_subnet" "brownbag_subnet" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.brownbag_vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.brownbag_vpc.id}"
  map_public_ip_on_launch = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "brownbag_gateway" {
  vpc_id = "${aws_vpc.brownbag_vpc.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.brownbag_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.brownbag_gateway.id}"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.brownbag_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.r.id}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "alb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.brownbag_vpc.id}"

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
  subnets         = ["${aws_subnet.brownbag_subnet.*.id}"]
  security_groups = ["${aws_security_group.alb.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.brownbag-target-grp.id}"
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
    target_group_arn = "${aws_alb_target_group.brownbag-target-grp.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/concourse/*"]
  }
}

resource "aws_alb_target_group" "brownbag-target-grp" {
  name     = "brownbag-target-grp"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.brownbag_vpc.id}"
}

resource "aws_alb_target_group" "nginx-target-grp" {
  name     = "nginx-target-grp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.brownbag_vpc.id}"
}


resource "aws_key_pair" "auth" {
  key_name   = "terraform"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "brownbag_security" {
  name = "brownbag_security"
  description = "Enable SSH and 8080"
  vpc_id      = "${aws_vpc.brownbag_vpc.id}"
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 8080
    to_port   = 8080

    security_groups = [
      "${aws_security_group.alb.id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    security_groups = [
      "${aws_security_group.alb.id}",
    ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
    ami = "ami-46134b51"
    instance_type = "t2.micro"
    # Our Security group to allow HTTP and SSH access
    vpc_security_group_ids = ["${aws_security_group.brownbag_security.id}"]

    # We're going to launch into the same subnet as our ELB. In a production
    # environment it's more common to have a separate private subnet for
    # backend instances.
    subnet_id = "${aws_subnet.brownbag_subnet.0.id}"
    connection {
      user = "ec2-user"
    }
    key_name = "${aws_key_pair.auth.id}"
    provisioner "file" {
      source = "concourse-docker.yml"
      destination = "/home/ec2-user/docker-compose.yml"
    }
    provisioner "remote-exec" {
        inline = [
          "mkdir -p keys/web keys/worker",
          "ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''",
          "ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''",
          "ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''",
          "cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys",
          "cp ./keys/web/tsa_host_key.pub ./keys/worker",
          "echo CONCOURSE_EXTERNAL_URL=http://${aws_instance.web.private_ip}:8080",
          "sudo curl -L \"https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
          "sudo chmod +x /usr/local/bin/docker-compose",
          "sleep 5",
          "docker-compose up -d"
        ]
    }
    tags {
        Name = "Concourse CI"
    }
}

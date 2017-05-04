variable "vpc_id" {}
variable "name" {}
variable "alb_id" {}
variable "concourse_target_arn" {}
variable "nginx_target_arn" {}
variable "ami" { default = "ami-46134b51" }
variable "instance_type" { default = "t2.micro" }
variable "public_key_name" {}
variable "public_key_path" {}
variable "subnet_id" {}

resource "aws_security_group" "brownbag_security" {
  name = "brownbag_security"
  description = "Enable SSH and 8080"
  vpc_id      = "${var.vpc_id}"
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
      "${var.alb_id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    security_groups = [
      "${var.alb_id}",
    ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb_target_group_attachment" "nginx" {
  target_group_arn = "${var.nginx_target_arn}"
  target_id = "${aws_instance.web.id}"
  port = 80
}
resource "aws_alb_target_group_attachment" "concourse" {
  target_group_arn = "${var.concourse_target_arn}"
  target_id = "${aws_instance.web.id}"
  port = 8080
}
resource "aws_key_pair" "auth" {
  key_name   = "${var.public_key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    # Our Security group to allow HTTP and SSH access
    vpc_security_group_ids = ["${aws_security_group.brownbag_security.id}"]

    # We're going to launch into the same subnet as our ELB. In a production
    # environment it's more common to have a separate private subnet for
    # backend instances.
    subnet_id = "${var.subnet_id}"
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
          "docker-compose up -d",
          "sleep 3",
          "docker run --name josh-nginx -p 80:80 -d nginx"
        ]
    }
    tags {
        Name = "Concourse CI"
    }
}

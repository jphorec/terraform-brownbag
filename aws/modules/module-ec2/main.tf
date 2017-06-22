# Module definition for EC2 instances
resource "aws_instance" "ec2" {
  ami           = "${var.ami_id}"     #"ami-46134b51"
  instance_type = "${var.ec2_instance_type}"
  key_name = "${var.ec2_key_name}"
  tags {
    Name = "${var.ec2_tag}"
  }
}

output "public_dns" {
  value = "${aws_instance.ec2.public_dns}"
}

output "key_name" {
  value = "${aws_instance.ec2.key_name}"
}
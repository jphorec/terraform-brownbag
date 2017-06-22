provider "aws" {
  region     = "us-east-1"
}

/*data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
*/
resource "aws_instance" "brownbag" {
  ami           = "ami-46134b51"
  instance_type = "t2.micro"
  key_name = "JoshKey"
  tags {
    Name = "brownbag"
  }
}

output "connection info" {
  value = "ssh -i ~/.ssh/${aws_instance.brownbag.key_name}.pem ec2-user@${aws_instance.brownbag.public_dns}"
}

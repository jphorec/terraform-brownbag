provider "aws" {
  region     = "us-east-1"
}

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

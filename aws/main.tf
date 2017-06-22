provider "aws" {
  region     = "us-east-1"
}

module "aws_ecs_instance" {
  source = "modules/module-ec2"
  ami_id =  "ami-46134b51"
  ec2_instance_type = "t2.micro"
  ec2_key_name = "JoshKey"
  ec2_tag = "brownbag"
}

output "connection info" {
  value = "ssh -i ~/.ssh/${module.aws_ecs_instance.key_name}.pem ec2-user@${module.aws_ecs_instance.public_dns}"
}

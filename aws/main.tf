provider "aws" {
  region = "us-east-1"
}

module "concourse" {
  source = "modules/module-concourse"
  name = "brownbag"
  route53_zone = "ZTK5H73BMWAZ0"
  route53_name = "joshhorecny.com"
  route53_type  = "A"
  instance_type = "t2.micro"
  public_key_name = "brownbag"
  public_key_path = "~/.ssh/brownbag.pem"
}


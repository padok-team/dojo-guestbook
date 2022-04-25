terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
  }
}

provider "aws" {
  profile = "padok-lab"
  region  = "eu-west-3"
}


resource "aws_security_group" "dojo" {
  name   = local.env_name
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow Ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all outgoing"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = local.common_tags
}

data "aws_ami" "ubuntu_20_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_instance" "dojo" {
  for_each = local.github_usernames

  vpc_security_group_ids = [aws_security_group.dojo.id]

  ami           = data.aws_ami.ubuntu_20_04.id
  instance_type = "t3a.large"
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  associate_public_ip_address = true

  # vpc_security_group_ids = [aws_security_group.dojo.id]
  subnet_id              = aws_subnet.subnet_primary.id

  user_data = templatefile("./userdata.yaml.tpl", {
    github_username = each.key
  }
  )
  user_data_replace_on_change = true
  tags                        = local.common_tags
}


# --- SSM Policies ---

data "aws_iam_policy_document" "ec2_sts_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }

}
resource "aws_iam_role" "ec2" {
  name_prefix        = "${local.env_name}_"
  assume_role_policy = data.aws_iam_policy_document.ec2_sts_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${local.env_name}_"
  role        = aws_iam_role.ec2.name
}

data "aws_route53_zone" "selected" {
  name         = "aws.padok.cloud"
}

resource "aws_route53_record" "vm" {
  for_each = local.github_usernames

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.key}.aws.padok.cloud"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.dojo[each.key].public_ip]
}


# Output

output "public_dns" {
  value = {for user in local.github_usernames: user => "ssh ${user}@${user}.aws.padok.cloud"}
}

data "aws_subnet" "selected" {
  id = var.vpc_subnet_ids[0]
}

resource "aws_security_group" "bastion_ssh" {
  name_prefix = "${var.bastion_name}-"
  description = "Allow SSH access to the ${var.bastion_name} bastion"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.bastion_name}-ssh"
  }
}

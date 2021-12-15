# IAM Instance Profile and accompanying roles and imbedded policies for the bastion.

resource "aws_iam_role" "bastion_role" {
  name_prefix = "${var.bastion_name}-"
  description = "Bastion instance profile role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

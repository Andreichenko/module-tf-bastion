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

resource "aws_iam_role_policy" "bastion_s3" {
  name = "bastion-s3"
  role = aws_iam_role.bastion_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Sid": "AllowBucketListing",
    "Action": [
      "s3:ListBucket"
    ],
    "Resource": [
      "${var.arn_prefix}:s3:::${local.infrastructure_bucket.id}"
    ],
    "Effect": "Allow"
  },
  {
    "Sid": "LimitAccessOnlyToSubKey",
    "Action": [
      "s3:PutObject",
      "s3:GetObject"
    ],
    "Resource": [
      "${var.arn_prefix}:s3:::${local.infrastructure_bucket.id}/${var.infrastructure_bucket_bastion_key}/*"
    ],
    "Effect": "Allow"
  }
  ]
}
EOF

}
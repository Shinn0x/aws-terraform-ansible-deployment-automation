# Allow EC2 instances to assume the role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

# Create the IAM role for the EC2 instance
resource "aws_iam_role" "ec2" {
  name               = "${var.name}-role"
  description        = "EC2 web server role: AWS Systems Manager access"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach the AWS managed policy for Systems Manager (Session Manager, Run Command)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the instance profile so EC2 can use the role
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-profile"
  role = aws_iam_role.ec2.name
}

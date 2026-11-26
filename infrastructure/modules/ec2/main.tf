# Get the latest Amazon Linux 2023 AMI (AWS keeps this parameter up to date)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Create the EC2 instance for the web server
resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true

  # Require IMDSv2 for instance metadata
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt the root disk
  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = var.name
  }

  # Keep the instance when AWS releases a newer AMI
  lifecycle {
    ignore_changes = [ami]
  }
}

# Keep the same public IP when the instance stops and starts
resource "aws_eip" "web" {
  domain   = "vpc"
  instance = aws_instance.web.id

  tags = {
    Name = var.name
  }
}

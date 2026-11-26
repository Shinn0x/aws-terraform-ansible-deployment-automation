terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "shinn-terraform-state-foundation"
    key          = "vpc/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

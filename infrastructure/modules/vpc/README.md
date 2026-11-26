# VPC Module

Creates the network for one environment.

| Resource | Name tag | Purpose |
|---|---|---|
| `aws_vpc` | `<name>-vpc` | VPC with DNS support and DNS hostnames enabled |
| `aws_subnet` | `<name>-public-subnet` | One public subnet in the first available zone. Instances get a public IP on launch. |
| `aws_internet_gateway` | `<name>-igw` | Internet access for the VPC |
| `aws_route_table` | `<name>-public-rt` | Route table for the public subnet |
| `aws_route` | | Sends `0.0.0.0/0` to the internet gateway |
| `aws_route_table_association` | | Connects the public subnet to the public route table |

The module has no provider, backend or locals. The environment that calls it (`infrastructure/environments/dev` or `prod`) configures the provider and the S3 backend, and its `default_tags` add `Project`, `Environment` and `ManagedBy`.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name_prefix
  vpc_cidr           = "10.20.0.0/16"
  public_subnet_cidr = "10.20.1.0/24"
}
```

Give each environment its own CIDR range (dev `10.20.0.0/16`, prod `10.30.0.0/16`), so they never overlap if they are connected later.

## Inputs

| Name | Description |
|---|---|
| `name` | Prefix for the Name tags, usually `local.name_prefix` |
| `vpc_cidr` | CIDR block for the VPC |
| `public_subnet_cidr` | CIDR block for the public subnet, inside `vpc_cidr` |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC, for the `security-group` module |
| `public_subnet_id` | ID of the public subnet, for the `ec2` module |
| `public_subnet_availability_zone` | Availability zone of the public subnet |
| `internet_gateway_id` | ID of the internet gateway |
| `public_route_table_id` | ID of the public route table |

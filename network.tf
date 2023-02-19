data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

output "aws_vpc_main_id" {
  value = aws_default_vpc.default_vpc.id
}

output "vpc_cidr_block" {
  value = aws_default_vpc.default_vpc.cidr_block
}

output "aws_availability_zone1" {
  value = aws_default_subnet.default_az1.availability_zone
}

output "aws_availability_zone2" {
  value = aws_default_subnet.default_az2.availability_zone
}

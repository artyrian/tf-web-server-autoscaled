data "aws_availability_zones" "available" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

output "aws_availability_zone1" {
  value = aws_default_subnet.default_az1.availability_zone
}

output "aws_availability_zone2" {
  value = aws_default_subnet.default_az2.availability_zone
}

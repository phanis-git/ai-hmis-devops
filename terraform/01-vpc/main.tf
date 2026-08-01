# Creating VPC
resource "aws_vpc" "main" {
    cidr_block       = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}"  //ai-hmis-dev
        }
    )
}

# # Creating Subnets for public , private and database
# public subnet
resource "aws_subnet" "public" {
count = length(var.public_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    map_public_ip_on_launch = true
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.availability_zone[count.index]
    tags =  merge(
            local.common_tags,
            {
                Name = "${local.name_prefix}-public-${local.availability_zone[count.index]}"  # ai-hmis-dev-public-us-east-1a
            }
        )
}
# private subnet
resource "aws_subnet" "private" {
count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
   availability_zone = local.availability_zone[count.index]
  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-private-${local.availability_zone[count.index]}"
        }
    )
}
# database subnet
resource "aws_subnet" "database" {
count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
   availability_zone = local.availability_zone[count.index]
   map_public_ip_on_launch = true
  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-database-${local.availability_zone[count.index]}"
        }
    )
}

# Creating Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}"  # ai-hmis-dev
        }
    )
}


# Public route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-public"
        }
    )
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-private"
        }
    )
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-database"
        }
    )
}


# public route with internet gateway
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}
# private route with nat gateway
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
# database route with nat gateway
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# Elastic Ip creation
resource "aws_eip" "nat" {
  domain   = "vpc"
   tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-elastic-ip"
        }
    ) 
}

# NAT gateway 
# Here we can use 2 nat gateways for both public subnets like us-east-1a and us-east-1b but due to more charges we created only one with 0th index of public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-nat"
        }
    ) 

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# Route table association
# public   as we have two subnets us-east-1a and us-east-1b we need to toop
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
  subnet_id      =   aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# private
resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
  subnet_id      =   aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
# Database
resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
  subnet_id      =   aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# SSM Parameters to share VPC info with other Terraform state folders
resource "aws_ssm_parameter" "vpc_id" {
  name  = "${var.project_name}-${var.env}-vpc-id"
  type  = "String"
  value = aws_vpc.main.id
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "${var.project_name}-${var.env}-vpc-cidr"
  type  = "String"
  value = aws_vpc.main.cidr_block
  tags  = local.common_tags
}

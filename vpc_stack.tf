resource "aws_vpc" "redshift_vpc" {
  cidr_block = "10.0.1.0/16"


  tags = {
    Name = "amatullah"
  }
}

resource "aws_subnet" "redshift_subnet1" {
  vpc_id     = aws_vpc.redshift_vpc.id
  availability_zone = "eu-west-1"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "amatullah"
  }
}

resource "aws_subnet" "redshift_subnet2" {
  vpc_id     = aws_vpc.redshift_vpc.id
  availability_zone = "eu-west-2"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "amatullah"
  }
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "amatullah_subnet_group"
  subnet_ids = [aws_subnet.redshift_subnet1.id, aws_subnet.redshift_subnet2.id]

  tags = {
    Name = "amatullah"
  }
}

resource "aws_internet_gateway" "the_gateway" {
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    Name = "amatullah"
  }
}

resource "aws_route_table" "redshift_route_table" {
  vpc_id = aws_vpc.redshift_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.the_gateway.id
  }

  tags = {
    Name = "amatullah"
  }
}

resource "aws_route_table_association" "associate_table1" {
  subnet_id      = aws_subnet.redshift_subnet1.id
  route_table_id = aws_route_table.redshift_route_table.id
}

resource "aws_route_table_association" "associate_table2" {
  subnet_id      = aws_subnet.redshift_subnet2.id
  route_table_id = aws_route_table.redshift_route_table.id
}

resource "aws_security_group" "redshift_sg" {
  name   = "redshift-sg"
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    name= "amatullah"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_access" {
  security_group_id = aws_security_group.redshift_sg.id
  cidr_ipv4         = aws_vpc.redshift_vpc.cidr_block
  from_port         = 5439
  to_port           = 5439
  ip_protocol       = "tcp"
  description       = "Allow inbound access"
}

resource "aws_vpc_security_group_egress_rule" "outbound_access" {
  security_group_id = aws_security_group.redshift_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow outbound traffic"
}


resource "aws_redshift_cluster" "redshift" {
  cluster_identifier        = "amatullah-redshift-cluster"
  database_name             = "testing_redshift"
  master_username           = "mahmud_amatullah"
  master_password           = "password"
  node_type                 = "dc2.large"
  cluster_type              = "multi-node"
  number_of_nodes           = 3
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids    = aws_security_group.redshift_sg.id
  publicly_accessible       = true

  tags = {
    Name = "amatullah-redshift-cluster"
  }
}
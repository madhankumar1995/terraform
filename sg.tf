resource "aws_security_group" "doohp-db-sg" {
  name        = "DB_traffic"
  description = "Allow DB inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.doohp-compute-sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "doohp-${var.environment}-db-sg"
  }
}

resource "aws_security_group" "doohp-compute-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "doohp-${var.environment}-compute-sg"
  }
}

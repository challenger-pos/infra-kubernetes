resource "aws_security_group" "challengeone_sg" {
  name        = "${var.projectName}-sg"
  description = "Enables access to the ChallengeOne application"
  vpc_id      = aws_vpc.vpc_challengeone.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["<CIDR_DO_SEU_GATEWAY>"]  # Exemplo: ["10.0.0.0/16"] para VPC interna ou ["1.2.3.4/32"] para IP específico
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
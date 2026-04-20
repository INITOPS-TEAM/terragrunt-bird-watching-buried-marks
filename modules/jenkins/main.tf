# IAM Role for Jenkins
resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-${var.env}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_admin" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-${var.env}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins" {
  name   = "${var.project_name}-${var.env}-jenkins-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project_name}-${var.env}-jenkins-sg" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_outbound" {
  security_group_id = aws_security_group.jenkins.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow Jenkins to access the Internet"
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_8080" {
  security_group_id = aws_security_group.jenkins.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  description       = "Jenkins UI from internal network"
}

# Jenkins volume
resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = var.nat_az
  size              = 20
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-${var.env}-jenkins-data"
  }
}

# Jenkins instance
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type_jenkins
  key_name      = var.key_name

  subnet_id                   = var.compute_subnet_id
  associate_public_ip_address = false

  lifecycle {
    prevent_destroy = true
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]
  iam_instance_profile = aws_iam_instance_profile.jenkins.name


  user_data = file("${path.module}/install_jenkins.sh")

  tags = {
    Name        = "${var.project_name}-${var.env}-jenkins"
    Environment = var.env
    Project     = var.project_name
    Role        = "jenkins"
    ManagedBy   = "Terraform"
  }
}

resource "aws_volume_attachment" "jenkins_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.jenkins_data.id
  instance_id = aws_instance.jenkins.id
}

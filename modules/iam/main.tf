# Role for apk servers and the birdwatch database (gives rights to the bucket and connects the SMM)
resource "aws_iam_role" "app_role" {
  name = local.app_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Adding rights to the bucket
resource "aws_iam_policy" "birdwatching_s3" {
  name = "${var.project_name}-${var.env}-birdwatching-s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
      Resource = ["arn:aws:s3:::${var.project_name}-${var.env}-*", "arn:aws:s3:::${var.project_name}-${var.env}-*/*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.birdwatching_s3.arn
}


resource "aws_iam_role_policy_attachment" "app_ssm_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project_name}-${var.env}-app-profile"
  role = aws_iam_role.app_role.name
}

# Minimal  role for SMM connection
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-${var.env}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-${var.env}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

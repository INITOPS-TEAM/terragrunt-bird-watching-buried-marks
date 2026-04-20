resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-${var.env}-key"
  public_key = file(var.public_key_path)
}

output "jenkins_instance_profile_name" {
  value       = aws_iam_instance_profile.jenkins.name
}
output "jenkins_sg_id" {
  value       = aws_security_group.jenkins.id
}

output "jenkins_role_arn" {
  description = "ARN of the Jenkins IAM role"
  value       = aws_iam_role.jenkins.arn
}

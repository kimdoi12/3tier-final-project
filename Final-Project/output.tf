# output "public_ip" {
#   value       = aws_instance.ec2-nginx.public_ip
#   description = "The public IP of the Instance"
# }

# output "public_dns" {
#   value       = aws_instance.ec2-nginx.public_dns
#   description = "The Public dns of the Instance"
# }

# output "private_ip" {
#   value       = aws_instance.ec2-nginx.private_ip
#   description = "The Private_ip of the Instance"
# }

output "tomcat_lb_dns" {
  value = aws_lb.TOMCAT-ELB.dns_name
  description = "DNS Name of TOMCAT_ELB"
}
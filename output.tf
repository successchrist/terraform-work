output "aws_ami_id" {
 value =  data.aws_ami.latest_amazon_linux_image
}
output "ec2_public_ip" {
  value = aws_instance.myapp_server.public_ip
}
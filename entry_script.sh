 #!/bin/bash
 sudo yum update -y && sudo yum install docker -y
 systemctl start docker
 add ec2_user to docker group
 sudo usermod-aG docker ec2_user
 docker run -p 8080:80 nginx

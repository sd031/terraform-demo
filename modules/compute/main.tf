# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = var.vpc_id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# resource "aws_key_pair" "auth" {
#   key_name   = var.key_name
#   public_key = file(var.public_key_path)
# }

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type = "ssh"
    # The default username for our AMI
    user = "ubuntu"
    host = self.public_ip
    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t3.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = var.aws_amis[var.aws_region]

  # The name of our SSH keypair we created above.
  # key_name = aws_key_pair.auth.id

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.default.id]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = var.subnet_id

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo our first web server > /var/www/html/index.html'
                EOF

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt-get -y install nginx",
  #     "sudo service nginx start",
  #   ]
  # }
}
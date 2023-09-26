terraform {
  backend "s3" {
    bucket = "sept-22-terraform-state-bucket-123"
    key    = "path/terraform.tfsstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {

      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
# resource "aws_vpc" "example" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_instance" "demo-instance" {
#   ami           = "ami-04cb4ca688797756f"
#   instance_type = "t2.micro"
#   key_name = "linuxdemokey"

#   tags = {
#     Name = "demo machine terraform"
#   }
# }
# #eip

# resource "aws_eip" "lb" {
#   instance = aws_instance.demo-instance.id
  
# }

#creating the new infrastrcuture
# creating the vpc
resource "aws_vpc" "east-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "east-vpc"
}
}
#creating the subnet

resource "aws_subnet" "east_subnet_1a" {
  vpc_id     = aws_vpc.east-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "east_subnet_1a"
  }
}
resource "aws_subnet" "east_subnet_1b" {
  vpc_id     = aws_vpc.east-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch ="true" 
  tags = {
    Name = "east_subnet_1b"
  }
}
resource "aws_subnet" "east_subnet_1c" {
  vpc_id     = aws_vpc.east-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "east_subnet_1c"
  }
}
#instance 

resource "aws_instance" "web-1" {
  ami           =var.web-1-ami-id
  #"ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = aws_key_pair.useast_keys.id
  subnet_id = aws_subnet.east_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  
  tags = {
    Name = "webserver-1"
  }
}
resource "aws_instance" "web-2" {
  ami           = var.web-1-ami-id
  #"ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = aws_key_pair.useast_keys.id
  subnet_id = aws_subnet.east_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  tags = {
    Name = "webserver-2"
  }
}
resource "aws_instance" "web-3" {
  ami           = var.web-1-ami-id
  #"ami-0899a01fa13081b12"
  instance_type = "t2.micro"
  key_name = aws_key_pair.useast_keys.id
  subnet_id = aws_subnet.east_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  tags = {
    Name = "webserver-3"
  }
}
#keypair
resource "aws_key_pair" "useast_keys" {
  key_name   = "useast-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCYWPO7GMyL+NAl1mfDo3hfGkT2XBSoupy9bZzTc+CTLA+iAhXrTIfIOqpCMhJdwZWoMXABvY+tFr/xYmcK5UDk953TtKUzQMukxeV/P+A1pKiJVpIrlXC9fwhHG0feHCjCxicrcUG+8nYKRSHQqQ1jLUoqA2UHhHndXu2S6riWSZw008PRA8b6n2ccqH68L7ioDnJfoZdPjr1GiMOxJ095ZhAgNhIdCs9IWEPilPsFxn7eZnQKNRvTPegodoI7v/RaC4xdUeOAaRHxtKa4JsJy6IEhaZVzNOXIpUQiqqnYyKPnwTQfbtr9KJv4MnV2VeaH/fffb4Vvlzw183I6cyLE97zKAFhyHROO6ouTz3kSyQ11smdkM+tHPGI8Irxlck26auRkJBdGvTzqYamq5LLk2lyFJrapeY4z1iJE8q/k2rmIe1ypO7wOKbiB2H89yHVJBUijkjj4UQT+VRflkRxkPQBMv6gBk86a67zMTEwIVQCTxdNORqtWpQSfrmhSddM= sunee@Suneetha"
}
#Security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_http-ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.east-vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
#create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.east-vpc.id

  tags = {
    Name = "useast-vpc-IG"
  }
}
#creating the Route table
resource "aws_route_table" "useast_RT_public" {
  vpc_id = aws_vpc.east-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "useast-RT-public"
  }
}

resource "aws_route_table" "useast_RT_private" {
  vpc_id = aws_vpc.east-vpc.id
  
  tags = {
    Name = "useast-RT-private"
  }
}
#Rt Assosicate
resource "aws_route_table_association" "RT_asso_1a" {
  subnet_id      = aws_subnet.east_subnet_1a.id
  route_table_id = aws_route_table.useast_RT_public.id
}
resource "aws_route_table_association" "RT_asso_1b" {
  subnet_id      = aws_subnet.east_subnet_1b.id
  route_table_id = aws_route_table.useast_RT_public.id
}
resource "aws_route_table_association" "RT_asso_1c" {
  subnet_id      = aws_subnet.east_subnet_1c.id
  route_table_id = aws_route_table.useast_RT_private.id
}
# #target group

 resource "aws_lb_target_group" "card-website-TG-terraform" {
  name     = "card-website-TG-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.east-vpc.id
}
# #attaching the target group
resource "aws_lb_target_group_attachment" "TG-instance-1" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "TG-instance-2" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "TG-instance-3" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-3.id
  port             = 80
}
# creating the load balancer(LB)

resource "aws_lb" "card-website-LB-terraform"{
  name               = "card-website-LB-terraform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]
  subnets            = [aws_subnet.east_subnet_1a.id, aws_subnet.east_subnet_1b.id]
   
  tags={
    Environment="production"
  }
}

#   enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }
# }
#creating the listner
resource "aws_lb_listener" "card-website-listner" {
  load_balancer_arn = aws_lb.card-website-LB-terraform.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  }
}

#####creating the instances via ASG and we will attach the LB to it
# create Launch template

resource "aws_launch_template""LT-demo-terraform" {
  #name = "LT-demo-terraform"
  image_id="ami-053b0d53c279acc90"
  instance_type="t2.micro"
  key_name= aws_key_pair.useast_keys.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data = filebase64("example.sh")
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "demo-instance by terra"
    }
  }
  
}
#asg creation

 resource "aws_autoscaling_group" "demo-asg" {
  vpc_zone_identifier= [aws_subnet.east_subnet_1a.id,aws_subnet.east_subnet_1b.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  name="demo-as-terraform"
  target_group_arns = [aws_lb_target_group.card-website-TG-terraform-2.arn]
  
  launch_template {
    id      = aws_launch_template.LT-demo-terraform.id
    version = "$Latest"
  }
 }
#  #LB with ASG

  resource "aws_lb_target_group" "card-website-TG-terraform-2" {
  name     = "card-website-TG-terraform-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.east-vpc.id
  
}
#creating the listner
resource "aws_lb_listener" "card-website-listner-2" {
  load_balancer_arn = aws_lb.card-website-LB-terraform-2.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG-terraform-2.arn
  }
} 
resource "aws_lb" "card-website-LB-terraform-2"{
  name               = "card-website-LB-terraform-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]
  subnets            = [aws_subnet.east_subnet_1a.id,aws_subnet.east_subnet_1b.id]

  tags={
    Environment="production"
  }
}
#   enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }
# }

  
  
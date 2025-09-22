resource "aws_vpc" "pkvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "pksubnet1" {
  vpc_id                  = aws_vpc.pkvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pksubnet2" {
  vpc_id                  = aws_vpc.pkvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "pkigw" {
  vpc_id = aws_vpc.pkvpc.id
}

resource "aws_route_table" "pkrt" {
  vpc_id = aws_vpc.pkvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pkigw.id
  }
}

resource "aws_route_table_association" "pkrouteasso1" {
  subnet_id      = aws_subnet.pksubnet1.id
  route_table_id = aws_route_table.pkrt.id
}
resource "aws_route_table_association" "pkrouteasso2" {
  subnet_id      = aws_subnet.pksubnet2.id
  route_table_id = aws_route_table.pkrt.id
}

resource "aws_security_group" "pkwebsg" {
  name        = "websg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.pkvpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "pksg"
  }
}

resource "aws_s3_bucket" "pkbucket" {
  bucket = "pk-terraform-bucket-1234567890" # Bucket names must be globally unique
}

resource "aws_instance" "pkwebserver1" {
  ami                    = "ami-08982f1c5bf93d976"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.pkwebsg.id]
  subnet_id              = aws_subnet.pksubnet1.id
  user_data              = base64encode(file("update.sh"))
}
resource "aws_instance" "pkwebserver2" {
  ami                    = "ami-08982f1c5bf93d976"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.pkwebsg.id]
  subnet_id              = aws_subnet.pksubnet2.id
  user_data              = base64encode(file("update1.sh"))
}

resource "aws_lb" "pkalb" {
  name               = "pklb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pkwebsg.id]
  subnets            = [aws_subnet.pksubnet1.id, aws_subnet.pksubnet2.id]
  tags = {
    Name = "pklb"
  }
}

resource "aws_lb_target_group" "pklbtarget" {
  name     = "pklbtarget"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.pkvpc.id
  health_check {
    path                = "/"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "pktargetattach1" {
  target_group_arn = aws_lb_target_group.pklbtarget.arn
  target_id        = aws_instance.pkwebserver1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "pktargetattach2" {
  target_group_arn = aws_lb_target_group.pklbtarget.arn
  target_id        = aws_instance.pkwebserver2.id
  port             = 80
}

resource "aws_lb_listener" "pklblistener" {
  load_balancer_arn = aws_lb.pkalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pklbtarget.arn
  }

}

output "pkloadbalancer_dns" {
  value = aws_lb.pkalb.dns_name

}
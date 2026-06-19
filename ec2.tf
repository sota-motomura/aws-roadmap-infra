# EC2用IAMロール(SSM接続のため)
resource "aws_iam_role" "ec2" {
  name = "phase1-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "phase1-ec2-profile"
  role = aws_iam_role.ec2.name
}

# 最新のAmazon Linux 2023 AMIを取得
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


#20260619追加
resource "aws_launch_template" "app" {
  name_prefix   = "phase1-app-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Phase1 App Server - $(hostname)</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "app-server-asg" }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "phase1-app-asg"
  vpc_zone_identifier = [aws_subnet.app_1a.id, aws_subnet.app_1c.id]
  target_group_arns   = [aws_lb_target_group.app.arn]

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-server-asg"
    propagate_at_launch = true
  }
}

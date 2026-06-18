resource "aws_lb" "main" {
  name               = "phase1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  tags = { Name = "phase1-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "phase1-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "phase1-app-tg" }
}

resource "aws_lb_target_group_attachment" "app_1a" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app_1a.id
  port              = 80
}

resource "aws_lb_target_group_attachment" "app_1c" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app_1c.id
  port              = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
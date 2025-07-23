resource "aws_lb" "app_lb" {
  name            = "App-LB"
  subnets         = [for subnet in aws_subnet.bastion_subnet : subnet.id]
  internal        = false
  security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "app_lb_tg" {
  name     = "application-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}

resource "aws_lb_target_group_attachment" "app_lb_attachment" {
  depends_on       = [aws_instance.application_ec2]
  for_each         = { for key, value in aws_instance.application_ec2 : key => value }
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.test_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

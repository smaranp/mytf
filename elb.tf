/*
  Creating Application ELB and TG & Rules
*/

resource aws_lb_target_group "default_tg"{
  name     = join("-",[var.v_alb_tag,"dtg"])
  port     = 80
  protocol = "HTTP"
  vpc_id =aws_vpc.vpc1.id	
}
resource aws_lb_target_group "prepaid_tg"{
  name     = join("-",[var.v_alb_tag,"prepaidtg"])
  port     = 80
  protocol = "HTTP"
  vpc_id =aws_vpc.vpc1.id	
}

resource aws_lb_target_group "postpaid_tg"{
  name     = join("-",[var.v_alb_tag,"postpaidtg"])
  port     = 8080
  protocol = "HTTP"
  vpc_id =aws_vpc.vpc1.id	
}

resource aws_lb_target_group "data_tg"{
  name     = join("-",[var.v_alb_tag,"datatg"])
  port     = 80
  protocol = "HTTP"
  vpc_id =aws_vpc.vpc1.id	
}


resource "aws_lb" "aelb" {
  name               = var.v_alb_tag
  internal           = false
  load_balancer_type = "application"
  subnets            = slice(aws_subnet.sn.*.id,0,length(data.aws_availability_zones.azs.names))
  tags = {
    Environment = var.v_alb_tag
  }
}
resource "aws_lb_listener" "front_end" {
	port =var.v_aelb_def_port
	load_balancer_arn =aws_lb.aelb.arn
	default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_tg.arn
  }
}
/********************* ELB ERWD Rules ********************************/
resource "aws_lb_listener_rule" "r_prepaid_tg" {
   listener_arn = aws_lb_listener.front_end.arn
	condition {
    path_pattern {
      values = ["*prepaid*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prepaid_tg.arn
  }
}

resource "aws_lb_listener_rule" "r_postpaid_tg" {
   listener_arn = aws_lb_listener.front_end.arn
	condition {
    path_pattern {
      values = ["*postpaid*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.postpaid_tg.arn
  }
}
resource "aws_lb_listener_rule" "r_data_tg" {
   listener_arn = aws_lb_listener.front_end.arn
	condition {
    path_pattern {
      values = ["*data*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.data_tg.arn
  }
}

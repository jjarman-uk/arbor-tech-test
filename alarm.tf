resource "aws_cloudwatch_metric_alarm" "elb_5xx_alarm" {
  alarm_name          = "ELB_4XX_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "10"
  alarm_description   = "Alarm triggered when ELB 5xx error count exceeds 10 for 3 consecutive periods"
  alarm_actions       = [aws_sns_topic.my_topic.arn]

  dimensions = {
    LoadBalancerName = "nginx-alb"
  }
}

resource "aws_sns_topic" "my_topic" {
  name = "my_topic"
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name

  alarm_name          = aws_cloudwatch_metric_alarm.elb_5xx_alarm.alarm_name
  alarm_comparison_operator = aws_cloudwatch_metric_alarm.elb_5xx_alarm.comparison_operator
  alarm_threshold     = aws_cloudwatch_metric_alarm.elb_5xx_alarm.threshold
  alarm_period        = aws_cloudwatch_metric_alarm.elb_5xx_alarm.period
  alarm_evaluation_periods = aws_cloudwatch_metric_alarm.elb_5xx_alarm.evaluation_periods
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name

  alarm_name          = aws_cloudwatch_metric_alarm.elb_5xx_alarm.alarm_name
  alarm_comparison_operator = aws_cloudwatch_metric_alarm.elb_5xx_alarm.comparison_operator
  alarm_threshold     = aws_cloudwatch_metric_alarm.elb_5xx_alarm.threshold
  alarm_period        = aws_cloudwatch_metric_alarm.elb_5xx_alarm.period
  alarm_evaluation_periods = aws_cloudwatch_metric_alarm.elb_5xx_alarm.evaluation_periods
}
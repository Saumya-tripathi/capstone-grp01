# Resources: SNS
resource "aws_sns_topic" "water_management" {
  name = "water_management"
}

resource "aws_sns_topic_subscription" "water_management_subscription" {
  topic_arn = aws_sns_topic.water_management.arn
  protocol  = "email"
  endpoint  = "${var.email_id}"
}
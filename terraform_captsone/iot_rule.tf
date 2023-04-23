resource "aws_iam_role" "iot" {
  name               = "iot"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "iot.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_kinesis_policy" {
  name = "iot_kinesis_policy"
  role = aws_iam_role.iot.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["kinesis:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "iot_kinesis_policy_01" {
  policy = aws_iam_role_policy.iot_kinesis_policy.name
  target = aws_iot_certificate.cert01.arn  # change
}

resource "aws_iot_policy_attachment" "iot_kinesis_policy_02" {
  policy = aws_iam_role_policy.iot_kinesis_policy.name
  target = aws_iot_certificate.cert02.arn  # change
}

resource "aws_iot_topic_rule" "rule_01" {
  name        = "data_stream"
  description = "Kinesis Rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/sprinkler01'"
  sql_version = "2015-10-08"

  kinesis {
    role_arn    = aws_iam_role.iot.arn
    stream_name = aws_kinesis_stream.data_stream.name
  }
}

resource "aws_iot_topic_rule" "rule_02" {
  name        = "data_stream"
  description = "Kinesis Rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/sprinkler02'"
  sql_version = "2015-10-08"

  kinesis {
    role_arn    = aws_iam_role.iot.arn
    stream_name = aws_kinesis_stream.data_stream.name
  }
}
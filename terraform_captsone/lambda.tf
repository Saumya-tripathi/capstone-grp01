# lambda
resource "aws_lambda_function" "raw_data_ingestion" {
  function_name = "raw_data_ingestion"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  timeout       = 10
  filename      = "${var.data_ingestion_lambda_filename}"
}
resource "aws_lambda_function" "raw_data_processor" {
  function_name = "raw_data_processor"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  timeout       = 10
  filename      = "${var.data_processor_lambda_filename}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# lambda - dynamo and sns policy policy
resource "aws_iam_role_policy" "with_lambda_policy" {
  name   = "with_lambda_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["dynamodb:*"],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["sns:*"],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "allow_kinesis_processing" {
  name   = "allow_kinesis_processing"
  path   = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["kinesis:*"],
        "Resource" : "arn:aws:kinesis:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["stream:*"],
        "Resource" : "arn:aws:stream:*:*:*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "kinesis_processing" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.allow_kinesis_processing.arn
}


resource "aws_lambda_event_source_mapping" "kinesis_lambda_mapping" {
  event_source_arn = aws_kinesis_stream.data_stream.arn
  function_name    = aws_lambda_function.raw_data_processor.arn
  starting_position = "LATEST"

  depends_on = [
    aws_iam_role_policy_attachment.kinesis_processing
  ]
}
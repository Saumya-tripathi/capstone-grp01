terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_id}"
  secret_key = "${var.access_key}"
}

# Resources: SNS
resource "aws_sns_topic" "water_management" {
  name = "water_management"
}

resource "aws_sns_topic_subscription" "water_management_subscription" {
  topic_arn = aws_sns_topic.water_management.arn
  protocol  = "email"
  endpoint  = "${var.email_id}"
}

# Resources: DynamoDb
resource "aws_dynamodb_table" "device_metadata" {
  name           = "device_metadata"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  attribute {
    name = "device_id"
    type = "S"
  }
  hash_key       = "device_id"
}
resource "aws_dynamodb_table" "weather_data" {
  name           = "weather_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  attribute {
    name = "weather_def_id" #cityName#Type(Current/ForeCast)#TimeStamp
    type = "S"
  }
  hash_key       = "weather_def_id"
}
resource "aws_dynamodb_table" "sprinkler_data" {
  name           = "sprinkler_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  attribute {
    name = "sprinkler_id"
    type = "S"
  }
  hash_key       = "sprinkler_id"
}
resource "aws_dynamodb_table" "raw_data" {
  name           = "raw_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  attribute {
    name = "id"
    type = "S"
  }
  hash_key       = "id"
}
resource "aws_dynamodb_table" "processed_data" {
  name           = "processed_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  attribute {
    name = "id"
    type = "S"
  }
  hash_key       = "id"
}
# lambda - dynamo and sns role
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
# Resource Kinesis
resource "aws_kinesis_stream" "data_stream" {
  name             = "data_stream"
  shard_count      = 1
  retention_period = 48
}


resource "aws_lambda_event_source_mapping" "kinesis_lambda_mapping" {
  event_source_arn = aws_kinesis_stream.data_stream.arn
  function_name    = aws_lambda_function.raw_data_processor.arn
  starting_position = "LATEST"

  depends_on = [
    aws_iam_role_policy_attachment.kinesis_processing
  ]
}

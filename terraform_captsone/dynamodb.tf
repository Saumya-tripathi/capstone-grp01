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
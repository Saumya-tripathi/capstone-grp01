# Resource Kinesis
resource "aws_kinesis_stream" "data_stream" {
  name             = "data_stream"
  shard_count      = 1
  retention_period = 48
}

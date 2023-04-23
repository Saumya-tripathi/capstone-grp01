variable "region" {
  type       = string
  default     = "us-east-1"
}
variable "access_id" {
  type       = string
  default     = "your access id"
}
variable "access_key" {
  type       = string
  default     = "your access password"
}
variable "data_ingestion_lambda_filename" {
  type       = string
  default     = "weather-api.zip"
}
variable "data_processor_lambda_filename" {
  type       = string
  default     = "weather-api.zip"
}
variable "email_id" {
  type       = string
  default     = "your email id"
}

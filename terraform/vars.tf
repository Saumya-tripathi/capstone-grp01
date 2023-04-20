variable "region" {
  type       = string
  default     = "us-east-1"
}
variable "access_id" {
  type       = string
  default     = "AKIA4FKLCYN44QD3CUMV"
}
variable "access_key" {
  type       = string
  default     = "C6xpPjSqH5BanfF12jr/u9truz7gZBO9BRO0gz31"
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
  default     = "psitsaumya@gmail.com"
}
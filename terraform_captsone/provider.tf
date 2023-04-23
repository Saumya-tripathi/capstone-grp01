provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_id}"
  secret_key = "${var.access_key}"
}

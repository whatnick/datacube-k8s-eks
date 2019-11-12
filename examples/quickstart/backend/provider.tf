provider "aws" {
  region      = "${var.region}"
  max_retries = 10
  version = "~> 2.34"
}

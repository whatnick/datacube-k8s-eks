provider "aws" {
  region      = var.region
  version = "2.34"
  max_retries = 10
}

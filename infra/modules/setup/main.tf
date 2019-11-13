data "aws_caller_identity" "current" {
}

provider "kubernetes" {
  version = "~> 1.9"
  #load_config_file       = false
  #host                   = var.cluster_endpoint
  #cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = [
      "eks", "get-token",
      "--cluster-name", "${var.cluster_name}"
    ]
  }
}

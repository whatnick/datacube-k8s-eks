variable "service_account_roles" {
  type        = "list"
  default     = []
  description = "Specify custom IAM roles that can be used by pods on the k8s cluster"
}

resource "aws_iam_openid_connect_provider" "example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = "${data.aws_eks_cluster.eks.identity.0.oidc.0.issuer}"
}

data "aws_iam_policy_document" "trust_policy" {
  count     = length(var.service_account_roles)
  statement {
    sid = "1"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    # List of users
    principals {
      type = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.example.arn}"]
  }

    # Enforce MFA
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.example.url, "https://", "")}:sub"
      values   = [
        "system:serviceaccount:${var.service_account_roles[count.index].service_account_namespace}:${var.service_account_roles[count.index].service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "service_account_role" {
  count              = length(var.service_account_roles)
  name               = "${var.cluster_name}-${var.service_account_roles[count.index].name}"
  assume_role_policy = data.aws_iam_policy_document.trust_policy[count.index].json
}

resource "aws_iam_role_policy" "service_account_role_policy" {
  count  = length(var.service_account_roles)
  name   = "${var.cluster_name}-${var.service_account_roles[count.index].name}"
  role   = aws_iam_role.service_account_role[count.index].id
  policy = var.service_account_roles[count.index].policy
}
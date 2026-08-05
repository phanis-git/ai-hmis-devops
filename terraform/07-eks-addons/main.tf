resource "aws_eks_addon" "ebs_csi" {

  cluster_name = local.cluster_name
   service_account_role_arn = aws_iam_role.ebs_csi_role.arn

  addon_name = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"
   depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_policy,
    aws_eks_addon.coredns
  ]
}
resource "aws_eks_addon" "coredns" {

  cluster_name = local.cluster_name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_addon.kube_proxy
  ]
}
resource "aws_eks_addon" "kube_proxy" {

  cluster_name = local.cluster_name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

 depends_on = [
    aws_eks_addon.vpc_cni
  ]
}
resource "aws_eks_addon" "vpc_cni" {

  cluster_name = local.cluster_name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     aws_eks_addon.kube_proxy
#   ]
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {

  statement {

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        # data.aws_iam_openid_connect_provider.oidc.arn
         aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }

  }

}
resource "aws_iam_role" "ebs_csi_role" {

  name = "${local.name_prefix}-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = local.common_tags
}
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {

  role = aws_iam_role.ebs_csi_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_iam_openid_connect_provider" "eks" {

  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}
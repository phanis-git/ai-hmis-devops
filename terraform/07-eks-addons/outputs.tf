output "addons" {

  value = [
    aws_eks_addon.ebs_csi.addon_name,
    aws_eks_addon.coredns.addon_name,
    aws_eks_addon.kube_proxy.addon_name,
    aws_eks_addon.vpc_cni.addon_name
  ]

}
output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}

output "cluster_name" {
  value = local.cluster_name
}
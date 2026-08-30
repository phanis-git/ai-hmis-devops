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



# required iam roles and policies for eks

# ==========================================
# 3. AWS LOAD BALANCER CONTROLLER IAM POLICY , policy created here, role created in 07.eks
# ==========================================

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {

  name = "AWSLoadBalancerControllerIAMPolicy"

  description = "IAM policy for AWS Load Balancer Controller"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "iam:CreateServiceLinkedRole"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:GetSecurityGroupsForVpc",
          "ec2:DescribeIpamPools",
          "ec2:DescribeRouteTables"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeListenerAttributes",
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "acm:ListCertificates",
          "acm:DescribeCertificate"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateSecurityGroup"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateTags"
        ]

        Resource = "arn:aws:ec2:*:*:security-group/*"

        Condition = {
          StringEquals = {
            "ec2:CreateAction" = "CreateSecurityGroup"
          }

          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]

        Resource = "arn:aws:ec2:*:*:security-group/*"

        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ]

        Resource = "*"

        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ]

        Resource = "*"

        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]

        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]

        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]

        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ]

        Resource = "*"

        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:AddTags"
        ]

        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]

        Condition = {
          StringEquals = {
            "elasticloadbalancing:CreateAction" = [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          }

          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]

        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },

      {
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:SetRulePriorities"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-aws-load-balancer-controller-policy"
    }
  )
}

# ==========================================
# AWS LOAD BALANCER CONTROLLER IAM ROLE
# ==========================================

resource "aws_iam_role" "aws_load_balancer_controller" {

  name = "${local.name_prefix}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${replace(
              data.aws_eks_cluster.eks.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:aud" = "sts.amazonaws.com"

            "${replace(
              data.aws_eks_cluster.eks.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-aws-load-balancer-controller-role"
    }
  )
}

# ==========================================
# Attach your policy to the role
# ==========================================
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {

  role = aws_iam_role.aws_load_balancer_controller.name

  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}


# installing aws load balancer for kubernetes



# --------------------------------------------------
# AWS Provider
# --------------------------------------------------



# --------------------------------------------------
# Kubernetes Provider
# --------------------------------------------------

provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.this.token
}


# --------------------------------------------------
# Helm Provider
# --------------------------------------------------
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}





# --------------------------------------------------
# AWS Load Balancer Controller Service Account
# --------------------------------------------------

resource "kubernetes_service_account" "aws_load_balancer_controller" {

  metadata {

    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      # "eks.amazonaws.com/role-arn" = data.aws_iam_role.aws_load_balancer_controller_role_arn.value
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
   
  }
  
}


# --------------------------------------------------
# AWS Load Balancer Controller Helm Release
# --------------------------------------------------

resource "helm_release" "aws_load_balancer_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  version = "1.14.0"

  namespace = "kube-system"

  create_namespace = false
# ----------------------------------------------------------
  # Helm values
  # ----------------------------------------------------------

  set = [
    {
      name  = "clusterName"
      value = var.eks_cluster_name
    },

    {
      name  = "region"
      value = var.aws_region
    },

    {
      name  = "vpcId"
      value = data.aws_vpc.main.id
    },

    {
      name  = "serviceAccount.create"
      value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]

  # EKS Cluster Name

  # values = {
  #   clusterName               = var.eks_cluster_name
  #   region                    = var.aws_region
  #   vpcId                     = var.vpc_id
  #   serviceAccount.create     = "false"
  #   serviceAccount.name       = "aws-load-balancer-controller"
  # }


  # Make Helm wait for ServiceAccount

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}

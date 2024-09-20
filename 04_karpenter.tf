module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.24"

  cluster_name = module.eks.cluster_name

  enable_pod_identity             = true
  create_pod_identity_association = true

  namespace          = "karpenter"
  iam_policy_name    = "${module.eks.cluster_name}-karpenter-controller"
  iam_role_name      = "${module.eks.cluster_name}-karpenter-controller"
  node_iam_role_name = "${module.eks.cluster_name}-karpenter-node"
  queue_name         = "karpenter-${module.eks.cluster_name}"

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.default_tags
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.0.0"
  create_namespace = true
  wait             = true

  values = [
    <<-EOT
    nodeSelector:
      node: initial
    tolerations:
      - key: node
        value: initial
        operator: Equal
        effect: NoSchedule
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]

  depends_on = [
    module.eks,
    module.karpenter
  ]
}

module "karpenter_node_default" {
  source = "./modules/karpenter_node"

  name                 = "default"
  cluster_name         = module.eks.cluster_name
  node_iam_role_name   = module.karpenter.node_iam_role_name
  consolidation_policy = "WhenEmptyOrUnderutilized"
  consolidate_after    = "30s"

  capacity_type = ["spot","on-demand"]

  depends_on = [
    helm_release.karpenter
  ]
}
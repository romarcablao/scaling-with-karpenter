apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: ${name}
spec:
  amiFamily: AL2
  role: ${node_iam_role_name}
  amiSelectorTerms:
    - id: "ami-03413b29e24337700"
    - id: "ami-07453250e58f72f3a"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
  tags:
    karpenter.sh/discovery: ${cluster_name}
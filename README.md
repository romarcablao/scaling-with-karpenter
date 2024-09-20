# Scaling With Karpenter

This repository is made for a demo in AWS Community Day Philippines 2024. You may also want to watch Karpenter in action [here](https://youtu.be/SQenMYCTCzs).

## Installation

Depending on your OS, select the installation method here: https://opentofu.org/docs/intro/install/

## Provision the infrastructure

1. Make necessary adjustment on the variables.
2. Run `tofu init` to initialize the modules and other necessary resources.
3. Run `tofu plan` to check what will be created/deleted.
4. Run `tofu apply` to apply the changes. Type `yes` when asked to proceed.

## Fetch `kubeconfig` to access the cluster

```bash
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
```

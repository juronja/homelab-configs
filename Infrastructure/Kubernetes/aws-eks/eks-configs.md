# EKS configurations

## Setup

1. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. Install [eksctl](https://eksctl.io/installation/#for-unix) and create cluster.
3. Connect with:

```shell
aws eks update-kubeconfig --region region-code --name my-cluster
```
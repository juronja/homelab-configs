# Kubernetes configurations

## Minimum hardware requirements

Master node: 2CPU, 2GB RAM
Worker node: 1CPU, 2GB RAM

## Install kubernetes

More info: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

### Master only

Initiate the cluster

```shell
sudo kubeadm init --control-plane-endpoint=192.168.x.x --node-name k8smaster1 --pod-network-cidr=10.244.0.0/16
```

Enable cluster access for current user (if not root)

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Add a Container Network Interface (overlay network)

```shell
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Worker only

Print join command on the **master**
```shell
kubeadm token create --print-join-command
```
Join workers to cluster with above join command



## Secrets usage

Generate a secret directly with `kubectl`. This will auto encode base64. More info:
https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/

```shell
kubectl create secret generic secret-name --from-file=username=./username.txt --from-file=password=./password.txt


kubectl create secret generic mongo-admin --from-file=MONGO_ADMIN_USER=/home/juronja/apps/utm-builder/creds/db-user.txt --from-file=MONGO_ADMIN_PASS=/home/juronja/apps/utm-builder/creds/db-pass.txt

```


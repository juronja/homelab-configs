# Kubernetes configurations

## On Premises

How to setup kubernetes on bare metal.

### Minimum hardware requirements

Master node: 2CPU, 2GB RAM
Worker node: 1CPU, 2GB RAM

### Install kubernetes

More info: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

#### Master only

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

#### Worker only

Print join command on the **master**
```shell
kubeadm token create --print-join-command
```
Join workers to cluster with above join command.


## Secrets usage

Generate a secret directly with `kubectl`. This will auto encode base64. More info:
https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/


Secret from `.env` file:

```shell
kubectl create secret generic mongo-admin -n utm-builder --from-env-file=$HOME/apps/utm-builder/.env
```

Secret for private docker registry. If you already ran `docker login`, you can copy that credential into Kubernetes:

```shell
kubectl create secret generic docker-secrets -n utm-builder --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
```


## Digital Ocean specifics


### Mongodb helm chart

Install helm repo
`helm repo add bitnami https://charts.bitnami.com/bitnami`

Values file for installing a mongodb helm chart against digital ocean.

```yaml
architecture: replicaset
auth:
    rootPassword: secret-pass
replicaCount: 3
persistence:
    storageClass: "do-block-storage" # This is digital ocean specific
```

Install with this code:
`helm install my-mongodb --values values.yaml bitnami/mongodb`


Add ingress controller

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install my-ingress-nginx ingress-nginx/ingress-nginx
```

create ingress rules:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mongo-express
spec:
  ingressClassName: nginx
  rules:
  - host: ingress.repina.eu
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mongo-express-service
            port:
              number: 8081
```
# Prometheus configurations

## Helm install
```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring --install
```

## Add custom rules

```shell
kubectl apply -f custom-alert-rules-and-alertmanager-prometheus-controller.yaml
```

Prometheus controller pod auto reloads the configuration with config-reloader container `kubectl logs prometheus-monitoring-kube-prometheus-prometheus-0 -n monitoring -c config-reloader`

Then in takes about 3 min to reload


## Forward UI to localhost

```shell
kubectl port-forward service/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
kubectl port-forward service/monitoring-kube-prometheus-alertmanager -n monitoring 9093:9093
kubectl port-forward service/monitoring-grafana -n monitoring 8080:80
```

## Alertmanager:

```shell
kubectl create secret generic gmail-auth -n monitoring --from-env-file=.env
kubectl apply -f custom-alert-rules-and-alertmanager-prometheus-controller.yaml

```

## Testing

Test with this image in kubernetes:

```shell
kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 120s --metrics-brief
```
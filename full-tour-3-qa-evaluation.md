{% include top_menu.md %}

# Go / No Go Quality Evaluation

This is step 3 of the tutorial. If you missed the previous parts, [start here](full-tour.md)

## Automating a Go or No Go Production Decision

In this step an automated go / no-go decision step will be added. If, based on your criteria, keptn decides the artifact is a `pass`, the release will be automatically promoted to production.
If the evaluation is a `failure`, the release will be blocked.

## Add Prometheus
To monitor the deployments, we need to add a monitoring provider. This tutorial will use Prometheus. Keptn currently supports the following providers:

{% include supported_monitoring_providers.md %}

Using the [web terminal](http://localhost{{ .site.ttyd_port }}), install Prometheus on the cluster:

```
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --namespace monitoring --wait
```

## Keptn Retrieves SLIs from Prometheus

Keptn needs to know how to interact with Prometheus; a keptn SLI provider service is used.

This service "knows" how to retrieve metrics from Prometheus so we need this **in addition to** Prometheus itself.

```
helm install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/{{ .site.prometheus_service_version }}/prometheus-service-{{ .site.prometheus_service_version }}.tgz --wait
kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/{{ .site.prometheus_service_version }}/deploy/role.yaml -n monitoring
```

{% include top_menu.md %}

# Production Quality Evaluations
This is step 4 of the tutorial. If you missed the previous parts, start [here](full-tour.md)

----

## Release Validation Quality Evaluation

In this step, a second quality evaluation step will be added to validate the health of production **after** deployment.

In a perfect world, a service would act identically in preproduction as production. In reality though, services can and will act differently in production for many different reasons.

Including an automated post-deployment quality evaluation provides an extra security check.

If this evaluation fails, it can be used as the trigger (or at least a strong indication) to rollback (or otherwise fix) the deployment.

## Add SLI and SLO files

Previously we added SLI and SLO definitions for `qa`. Add them now for the `production` stage.

In this demo, the same files will be used. In reality however, most likely different objectives would be used in production.

```
cd ~/keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=prometheus/sli.yaml --resourceUri=prometheus/sli.yaml
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=slo.yaml --resourceUri=slo.yaml
```

## Modify Shipyard

Modify the shipyard on the `main` branch again. After the `je-deployment` task, add two new tasks to the `production` stage:

```
- name: "je-test"
- name: "evaluation"
  properties:
    timeframe: "2m"
```

The shipyard should now look like this:

```
apiVersion: "spec.keptn.sh/0.2.2"
kind: "Shipyard"
metadata:
  name: "shipyard-delivery"
spec:
  stages:
    - name: "qa"
      sequences:
        - name: "delivery"
          tasks:
            - name: "je-deployment"
            - name: "je-test"
            - name: "evaluation"
              properties:
                timeframe: "2m"

    - name: "production"
      sequences:
        - name: "delivery"
          triggeredOn:
            - event: "qa.delivery.finished"
          tasks:
            - name: "approval"
              properties:
                pass: "automatic"
                warning: "automatic"
            - name: "je-deployment"
            - name: "je-test"
            - name: "evaluation"
              properties:
                timeframe: "2m"
```

> An additional `je-test` step is added so locust generates some load on the application. In a real production environment, this task would probably be unneccessary as production traffic would already be present.

----

## 🎉 Trigger Delivery

Trigger delivery of the "good build". This should:

1. Pass the `qa` quality gate and be automatically promoted to production
2. Pass the `production` quality gate and remain in production

```
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="{{ .site.image }}:{{ .site.good_version }}" \
--labels=image="{{ .site.image }}",version="{{ .site.good_version }}"
```

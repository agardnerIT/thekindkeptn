# End-to-End Delivery

If you have just installed the kind keptn, head here first to understand the out-of-the-box demo.

The following tutorial was heavily influenced this [excellent JES PoC tutorial](https://github.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc) by @christian-kreuzberger-dtx. Thanks Christian for doing the hard work!

## Goal

The goal of this tutorial is to
- Deploy a service (using `helm upgrade`)
- Run performance tests (using [locust](https://locust.io)) against this service

Step 1: Automated testing and releases into `qa` and `production` stages
Step 2: An approval step will be added to ensure a human must always click "go" before a production release.
Step 3: Prometheus will then be added to the cluster to monitor the workloads and quality evaluations will be added to ensure no bad build every makes it to production.
Step 4: SLO-based quality evaluations will be run in production, post rollout. If a bad deployment occurs, the quality gate will fail and remediation actions (rollback?) can easily be actioned.

## Create New Project

1. Please create a brand new, uninitialised Git repository
2. Save the following shipyard file which defines the new environment
3. Use the keptn's bridge to create the project visually OR use the [web terminal](http://localhost:{{ site.ttyd_port }}) to create the project

Web terminal command:
```
keptn create project fulltour \
--shipyard shipyard.yaml \
--git-remote-url <YOUR-GIT-REPO> \
--git-user <YOUR-GIT-USERNAME> \
--git-token <YOUR-GIT-PAT-TOKEN>
```

**shipyard.yaml**
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

    - name: "production"
      sequences:
        - name: "delivery"
          triggeredOn:
            - event: "qa.delivery.finished"
          tasks:
            - name: "je-deployment"
````


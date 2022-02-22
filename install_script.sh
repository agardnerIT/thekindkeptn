#!/usr/bin/env bash

# Set global variables
KEPTN_VERSION=0.12.2
JOB_EXECUTOR_SERVICE_VERSION=0.1.6

# This is the install script that is included in 'docker build' and executes on 'docker run'

echo "-- Bringing up a cluster --"
k3d cluster create mykeptn --config=/root/k3dconfig.yaml --wait

echo "-- Waiting for all resources to be ready (timeout 2 mins) --"
kubectl wait --for=condition=ready pods --all --all-namespaces --timeout=2m

echo "-- Installing Keptn via Helm. This will take a few minutes (timeout 10mins) --"
extra_params=""
if [ "$LOOK_AND_FEEL" == "CA" ]; then
  echo "   > Using Cloud Automation Look and Feel";
  extra_params="--set=control-plane.bridge.lookAndFeelUrl=https://github.com/agardnerIT/thekindkeptn/raw/main/ca/lookandfeel.zip"
  else
    echo "   > Using default look and feel";
fi

helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz $extra_params \
  -n keptn --create-namespace \
  --wait --timeout=10m \
  --set=control-plane.apiGatewayNginx.type=LoadBalancer

echo "-- Deleting bridge credentials for demo mode (no login required)"
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true

echo "-- Restart Keptn Bridge to load new settings --"
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

echo "-- Installing Job Executor Service --"
helm install -n keptn job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz

echo "-- Wait for all pods in Keptn namespace to signal ready. (timeout 2 mins) --"
kubectl -n keptn wait --for=condition=ready pods --all --timeout=2m

# host.docker.internal is a special address that routes to the host machine (eg. laptop)
echo "-- Authenticating keptn CLI --"
keptn auth --endpoint=http://host.docker.internal --api-token=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)

echo "-- Create Keptn Hello World Project --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/shipyard.yaml
keptn create project helloworld --shipyard=shipyard.yaml
keptn create service demoservice --project=helloworld

echo "-- Applying Job Config YAML File. This is the file the job-exector-service looks at to ultimately runs the helloworld container) --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/jobconfig.yaml
keptn add-resource --project=helloworld --service=demoservice --stage=demo --resource=jobconfig.yaml --resourceUri=job/config.yaml

echo "-- Downloading Sample Cloud Event JSON File --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/helloevent.cloudevent.json

echo "-- Triggering first Keptn Sequence --"
keptn send event -f helloevent.cloudevent.json
echo ========================================================
echo Keptn is now running
echo Visit: http://localhost from your machine
echo Type 'exit' to exit the docker container
echo ========================================================

# Start up a bash shell to try out thekindkeptn
cd
/bin/bash

# Clean up cluster after exit from shell
k3d cluster delete mykeptn

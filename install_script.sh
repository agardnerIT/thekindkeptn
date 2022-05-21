#!/usr/bin/env bash

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo "Preventing ungraceful shutdown. Please don't use Ctrl+C. Wait until the script has finished and then type: exit"
}

# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

# Set global variables
KIND_KEPTN_VERSION=0.0.15
KEPTN_VERSION=0.15.0
JOB_EXECUTOR_SERVICE_VERSION=0.2.0

# This is the install script that is included in 'docker build' and executes on 'docker run'
echo "------------------------------------------------------------------------"
echo " Keptn Installer $KIND_KEPTN_VERSION"
echo " DO NOT PRESS CONTROL + C to exit..."
echo " ONLY use 'exit'" 
echo " If things fail, LET THEM, then when you get the bash prompt, type: exit"
echo " This is required to gracefully cleanup docker and k3d before closing."
echo ""
echo " Installer will continue automatically in 5 seconds"
echo "------------------------------------------------------------------------"
sleep 5

echo "-- Installing Versions --"
echo "Keptn: $KEPTN_VERSION"
echo "Job Executor Service: $JOB_EXECUTOR_SERVICE_VERSION"

echo "-- Bringing up a cluster --"
k3d cluster create mykeptn --config=/root/k3dconfig.yaml --wait

# Add sleep before continuing to prevent misleading error
sleep 10

echo "-- Waiting for all core cluster resources to be ready (timeout 2 mins) --"
kubectl wait --for=condition=ready pods --all --all-namespaces --timeout=2m

echo "-- Installing Keptn via Helm. This will take a few minutes (timeout 10mins) --"
extra_params=""
if [ "$LOOK_AND_FEEL" == "CA" ]; then
  echo "   > Using Cloud Automation Look and Feel";
  extra_params="--set=control-plane.bridge.lookAndFeelUrl=https://d2ixiz0hn5ywb5.cloudfront.net/branding.zip"
  else
    echo "   > Using default look and feel";
fi

helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz $extra_params \
  -n keptn --create-namespace \
  --wait --timeout=10m \
  --set=control-plane.apiGatewayNginx.type=LoadBalancer

echo "-- Deleting bridge credentials for demo mode (no login required) --"
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true

echo "-- Restart Keptn Bridge to load new settings --"
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
echo "-- Installing Job Executor Service to namespace 'keptn-jes' (timeout=10m) --"
helm install \
--namespace keptn-jes --create-namespace \
--wait --timeout=10m \
--set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn \
--set=remoteControlPlane.api.token=$KEPTN_API_TOKEN \
--set=remoteControlPlane.topicSubscription="sh.keptn.event.hello-world.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz

echo "-- Installing Helm Service to namespace 'keptn' (timeout=10m) --"
helm install \
--namespace keptn --create-namespace \
--wait --timeout=10m \
helm-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/helm-service-$KEPTN_VERSION.tgz

echo "-- Installing JMeter Service to namespace 'keptn' (timeout=10m) --"
helm install \
--namespace keptn --create-namespace \
--wait --timeout=10m \
jmeter-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/jmeter-service-$KEPTN_VERSION.tgz

echo "-- Wait for all pods in Keptn namespace to signal ready. (timeout 2 mins) --"
kubectl -n keptn wait --for=condition=ready pods --all --timeout=2m

# host.docker.internal is a special address that routes to the host machine (eg. laptop)
echo "-- Authenticating keptn CLI --"
keptn auth --endpoint=http://host.docker.internal --api-token=$KEPTN_API_TOKEN

echo "-- Create Keptn Hello World Project --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/shipyard.yaml
keptn create project helloworld --shipyard=shipyard.yaml
keptn create service demoservice --project=helloworld

echo "-- Applying Job Config YAML File. This is the file the job-exector-service looks at to ultimately runs the helloworld container) --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/jobconfig.yaml
keptn add-resource --project=helloworld --service=demoservice --stage=demo --resource=jobconfig.yaml --resourceUri=job/config.yaml

echo "-- Triggering first Keptn Sequence --"
keptn trigger sequence --sequence hello --project helloworld --service demoservice --stage demo

echo ========================================================
echo Keptn is now running
echo Visit: http://localhost from your host machine
echo You can trigger a sequence from the bridge: http://localhost
echo Or using the Keptn CLI:
echo keptn trigger sequence --sequence hello --project helloworld --service demoservice --stage demo
echo Type 'exit' to exit the docker container
echo ========================================================

# Start up a bash shell to try out thekindkeptn
cd
/bin/bash

# Clean up cluster after exit from shell
k3d cluster delete mykeptn

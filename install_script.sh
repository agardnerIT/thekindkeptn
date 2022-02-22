#!/usr/bin/env bash

# This is the install script that is included in 'docker build' and executes on 'docker run'

echo "-- Bringing up a cluster --"
kind create cluster --image kindest/node:v1.17.0 --name thekindkeptn --config /root/kind.yaml

echo "-- Modifying Kubernetes config to point to Kind master node --"
MASTER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' thekindkeptn-control-plane)
sed -i "s/^    server:.*/    server: https:\/\/$MASTER_IP:6443/" $HOME/.kube/config

echo "-- Waiting for Nodes to Signal Ready (timeout 120s) --"
kubectl wait --for=condition=ready nodes --all --timeout=120s

echo "-- Installing Keptn via Helm --"
extra_params=""
if [ "$LOOK_AND_FEEL" == "CA" ]; then
  echo "-- Using cloud automation look and feel --";
  extra_params="--set=control-plane.bridge.lookAndFeelUrl=https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/ca/lookandfeel.zip"
  else
    echo "-- Using default look and feel --";
fi

helm install keptn https://github.com/keptn/keptn/releases/download/0.12.0/keptn-0.12.0.tgz -n keptn --create-namespace $extra_params

echo "-- Installing Job Executor Service --"
helm install -n keptn job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/0.1.6/job-executor-service-0.1.6.tgz

echo "-- Wait for all pods in Keptn namespace to signal ready. Timeout=20 mins --"
kubectl -n keptn wait --for=condition=ready pods --all --timeout=20m

echo "-- Expose Keptn to http://localhost on port 80 --"
# Patch api-gateway-nginx to include route from NodePort 31090 to 8080
# Remember that 31090 will then be mapped to 80 in the kind.yaml file
# So we can get to keptn from laptop on http://localhost
# If inside the docker container, we need to use NodePort IP and port combo for example
# export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
# curl $NODE_IP:31090
kubectl -n keptn patch service api-gateway-nginx -p '{"spec": {"ports": [{"port": 8080,"targetPort": 8080, "nodePort": 31090, "name": "httpnp"}],"type": "NodePort"}}'

echo "-- Deleting bridge credentials for demo mode (no login required)"
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true

echo "-- Restart Keptn Bridge to load new settings --"
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

echo "-- Authenticating keptn CLI --"
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
keptn auth --endpoint=http://$NODE_IP:31090 --api-token=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)

echo "-- Create Keptn Hello World Project --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/shipyard.yaml
keptn create project helloworld --shipyard=shipyard.yaml
keptn create service demoservice --project=helloworld

echo "-- Applying Job Config YAML File (this is the job-exector-service looks at to ultimately runs the helloworld container) --"
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
kind delete cluster --name thekindkeptn

#!/usr/bin/env bash

# This is the install script that runs on docker build

echo -- Bringing up a cluster --
bash -c '/usr/local/bin/kind create cluster --image kindest/node:v1.17.0 --name kind-keptn --config /root/kind.yaml'

echo Modifying Kubernetes config to point to Kind master node
MASTER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-keptn-control-plane)
sed -i "s/^    server:.*/    server: https:\/\/$MASTER_IP:6443/" $HOME/.kube/config

echo "-- Installing Keptn via Helm (this will take about 10 minutes) --"
helm install keptn https://github.com/keptn/keptn/releases/download/0.12.0/keptn-0.12.0.tgz -n keptn --create-namespace --wait

echo "-- Installing Job Executor Service --"
helm install -n keptn job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/0.1.6/job-executor-service-0.1.6.tgz --wait

echo "-- Expose Keptn to http://localhost on port 80 --"
# Patch api-gateway-nginx to include route from NodePort 31090 to 8080
# Remember that 31090 will then be mapped to 80 in hte kind.yaml file
# So we can get to keptn from laptop on http://localhost
# If inside the docker container, we need to use NodePort IP and port combo for example
# export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
# curl $NODE_IP:31090
kubectl -n keptn patch service api-gateway-nginx -p '{"spec": {"ports": [{"port": 8080,"targetPort": 8080, "nodePort": 31090, "name": "httpnp"}],"type": "NodePort"}}'

echo "-- Deleting bridge credentials for demo mode (no login required)"
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true

echo "-- Restart Keptn Bridge to load new settings --"
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

echo "-- Authenticating keptn CLI"
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
keptn auth --endpoint=http://$NODE_IP:31090 --api-token=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)

#echo "-- Create Keptn Hello World Project --"
wget https://raw.githubusercontent.com/agardnerIT/thekindkeptn/main/shipyard.yaml
keptn create project helloworld --shipyard=shipyard.yaml
keptn create service demoservice --project=helloworld

echo "-- Applying Job Config YAML File (this is the job-exector-service looks at to ultimately runs the helloworld container) --"
keptn add-resource --project=hello-world --service=demo --stage=dev --resource=jobconfig.yaml --resourceUri=job/config.yaml

echo ========================================================
echo Keptn is now running
echo Visit: http://localhost from your machine
echo ========================================================

# Start up a bash shell to try out kind-keptn
cd
/bin/bash

# Clean up cluster after exit from shell
kind delete cluster --name kind-keptn

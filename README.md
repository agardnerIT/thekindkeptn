# The Kind Keptn (Work In Progress)

This branch uses `k3d-dind` rather than kind.

```
git clone -b k3d https://github.com/agardnerIT/thekindkeptn
cd thekindkeptn
docker build -t thekindkeptn:k3d .
docker run -it -v /var/run/docker.sock:/var/run/docker.sock --rm --name k3dkeptn thekindkeptn:k3d
```

Once inside the container, run these steps (once working this will be moved to `install_script.sh` to automate):
```
k3d cluster create mykeptn --config=/root/k3dconfig.yaml
kubectl wait --for=condition=ready nodes --all --timeout=120s
kubectl wait --for=condition=ready pods --all --all-namespaces
keptn install --endpoint-service-type=LoadBalancer -y
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait
```

Bridge will be available passwordless via `http://localhost` but I'm struggling to get the endpoint for the `keptn auth` command.

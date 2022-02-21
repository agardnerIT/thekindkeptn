# The Kind Keptn (Work In Progress)

This branch uses `k3d-dind` rather than `kind`.

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

```

# docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                                         NAMES
df486f76143d   rancher/k3d-proxy:5.2.2    "/bin/sh -c nginx-pr…"   17 minutes ago   Up 16 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:44849->6443/tcp   k3d-mykeptn-serverlb
a00abd9b77fa   rancher/k3s:v1.21.7-k3s1   "/bin/k3s agent"         17 minutes ago   Up 16 minutes                                                 k3d-mykeptn-agent-0
c13bb3b2f731   rancher/k3s:v1.21.7-k3s1   "/bin/k3s server --d…"   17 minutes ago   Up 16 minutes                                                 k3d-mykeptn-server-0
04f9b681868a   thekindkeptn:k3d           "/bin/bash"              17 minutes ago   Up 17 minutes   2375-2376/tcp                                 k3dkeptn

# kubectl get pods -n keptn
NAME                                     READY   STATUS
svclb-api-gateway-nginx-x277m            1/1     Running
keptn-nats-cluster-0                     2/2     Running
secret-service-55857ccff-pvk7p           1/1     Running
api-service-7f9f6c7664-4b89z             2/2     Running
configuration-service-5d5d785765-ggcpd   1/1     Running
svclb-api-gateway-nginx-tmvkm            1/1     Running
api-gateway-nginx-7989496d84-27bg5       1/1     Running
remediation-service-65fcd5ff69-xpzr8     2/2     Running
mongodb-datastore-7c44dcbcf8-x2qzp       2/2     Running
bridge-9d9cc9c7c-wv6m5                   1/1     Running
webhook-service-5776bb7fff-g4f5w         2/2     Running
approval-service-bbb8858bb-clw9r         2/2     Running
statistics-service-fd668fbc5-fj68p       2/2     Running
lighthouse-service-fcbf56d8d-vw2bg       2/2     Running
keptn-mongo-56c8c56bd7-cwzp7             1/1     Running
shipyard-controller-7f8c6d8f94-r76f6     2/2     Running

# kubectl get services -n keptn
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP             PORT(S)
keptn-nats-cluster      ClusterIP      None            <none>                  4222/TCP,6222/TCP,8222/TCP,7777/TCP,7422/TCP,7522/TCP
lighthouse-service      ClusterIP      10.43.39.150    <none>                  8080/TCP
api-service             ClusterIP      10.43.4.140     <none>                  8080/TCP
configuration-service   ClusterIP      10.43.157.158   <none>                  8080/TCP
secret-service          ClusterIP      10.43.179.3     <none>                  8080/TCP
webhook-service         ClusterIP      10.43.107.146   <none>                  8080/TCP
mongodb-datastore       ClusterIP      10.43.96.21     <none>                  8080/TCP
remediation-service     ClusterIP      10.43.34.237    <none>                  8080/TCP
bridge                  ClusterIP      10.43.203.186   <none>                  8080/TCP
statistics-service      ClusterIP      10.43.153.253   <none>                  8080/TCP
approval-service        ClusterIP      10.43.168.30    <none>                  8080/TCP
keptn-mongo             ClusterIP      10.43.233.150   <none>                  27017/TCP
shipyard-controller     ClusterIP      10.43.111.234   <none>                  8080/TCP
api-gateway-nginx       LoadBalancer   10.43.196.84    172.18.0.2,172.18.0.3   80:30798/TCP
```

<img width="212" alt="image" src="https://user-images.githubusercontent.com/26523841/155036346-8523cee8-71a0-4400-90e3-3d3a92823d92.png">


Keptn UI (Bridge) will be available passwordless via `http://localhost`.

## Next Steps
How to `curl` to `http://localhost:80` on the host machine (potentially directly to the proxy)?

# The Kind Keptn

This branch uses `k3d-dind` rather than `kind`.

```
git clone -b k3d https://github.com/agardnerIT/thekindkeptn
cd thekindkeptn
docker build -t thekindkeptn:k3d .
docker run -it -v /var/run/docker.sock:/var/run/docker.sock:ro --rm --name k3dkeptn thekindkeptn:k3d
```

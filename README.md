# thekindkeptn (Work In Progress)

Run Keptn easily with `docker run`

```
docker build -t thekindkeptn:0.0.1 .
docker run --rm --name thekindkeptn -v /var/run/docker.sock:/var/run/docker.sock -it thekindkeptn:0.0.1
```

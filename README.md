# The Kind Keptn

![image](https://user-images.githubusercontent.com/26523841/154243627-5c57a5c4-dc2c-4835-8111-7418d3538ee7.png)

![image](https://user-images.githubusercontent.com/26523841/154243049-13a05813-62c7-4ff5-b633-11af78930470.png)

### Keptn in a Docker Container

This demo creates a single container with:
- A k8s cluster inside
- Helm is installed
- Keptn installed to the `keptn` namespace
- Keptn bridge and API are exposed on localhost on port `80`: `http://localhost`
- The [job executor service](https://github.com/keptn-contrib/job-executor-service)
- A demo "hello world" project is created
- Automatically runs a first "hello world" sequence for you

If you need additional Keptn services, just `docker exec -it thekindkeptn /bin/sh` then use `helm` to install services. `kubectl` is also available.

## Usage

> Warning: This is for demo purposes ONLY. It should NOT be used in production as `docker.sock` exposure is VERY dangerous. You've been warned.

You will need about 8GB of RAM to run this container (make sure docker resources are configured to allow 8GB RAM usage).
It will take around 10 minutes to completely spin up, so do `docker run` then go and grab a cup of coffee!

```
docker run --rm --name thekindkeptn -v /var/run/docker.sock:/var/run/docker.sock -it gardnera/thekindkeptn:0.0.1
```

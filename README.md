# The Kind Keptn (Work In Progress)

> This is still a work in progress. Use at your own risk.

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

## What Happened?
- We installed Kubernetes, Helm and Keptn into the docker container and exposed it to your localhost
- We also installed the job executor service. Keptn orchestrates other tools and services are a cornerstone of how it does that. Services abstract the details of dealing with the product and leave you free to get on with your day.
- Once everything was installed, a cloudevent was sent into Keptn's API (see `helloevent.cloudevent.json`)
- That cloudevent has a `type` in a specific format that tells Keptn to trigger the `hello` sequence in the `demo` stage (see `shipyard.yaml`)
- Keptn now knows it needs to trigger the task inside the `hello` sequence. So Keptn crafts and distributes another cloudevent, automatically on our behalf (`sh.keptn.event.hello-world.triggered`)
- It is this `hello-world.triggered` event that the job executor service is listening for
- The job executor looks for it's configuration (see `jobconfig.yaml`) and so spins up the `alpine` image to say hello!


The power of Keptn is that we've split our process (defined in the `shipyard.yaml`) from the tooling.

Want to get a Slack message instead of a container saying hello? Just swap your services and listen for the same `hello-world.triggered` event. You don't need to know how the Slack APIs work. Someone else has done that for you. Just uninstall the Job Executor Service and install the [notification service](https://github.com/keptn-contrib/notification-service).

Want to trigger a webhook? Just configure the webhook service to send an outbound POST to your tool.

The possibilities are endless.

## Troubleshooting

### Node Timeout
If you get stuck on `-- Waiting for Nodes to Signal Ready (timeout 120s) --` and the nodes never signal `Ready`, most likely Docker does not have enough resources. Go into the Docker settings and allow 8GB RAM.

### Nodes Already Exist
```
-- Bringing up a cluster --
ERROR: node(s) already exist for a cluster with the name "thekindkeptn"
```
This usually occurs when a previous run has failed and things have gotten a bit messed up. Expect lots more errors but it's an easy fix.

Just type `exit` and the cluster will be deleted.

Re-run the `docker run...` command and a new cluster will be created.


# The Kind Keptn

The kind keptn is designed as a disposable, temporary mechanism to quickly evaluate [keptn](https://keptn.sh). The only pre-requisite is docker.

The kind keptn is **not** designed as a production-ready installation. It is **not** designed for long term use. For those, you want [a proper installation of keptn](https://keptn.sh/docs/quickstart) or a SaaS hosted version.

This microsite covers the basics of thekindkeptn. Full docs and tutorials are found on the [keptn site](https://keptn.sh).

## Quick Start

```
docker run --rm -it \
--name thekindkeptn \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
--add-host=host.docker.internal:host-gateway \
--publish 7681:7681 \
gardnera/thekindkeptn:0.0.15
```

## I've Installed. What Now?

See [first steps](first-steps.md) to start the keptn discovery path.

## Quick Links
- Browser based web terminal to interact with the cluster: `http://localhost:7681`
- Keptn's bridge: `http://localhost/bridge`

## Components

See [components](components.md) for what is installed when you run the above command

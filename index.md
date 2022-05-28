# The Kind Keptn

The kind keptn is designed as an easy way to evaluate [keptn](https://keptn.sh). The kind keptn is a disposable, fully functional kubernetes cluster, powered by k3d and all wrapped inside a single docker command.

The kind keptn is **not** designed for production or long term use. It is **not** designed to replace a [proper keptn installation](https://keptn.sh/docs/quickstart)

## Components

So what do you get when you run the kind keptn?

1. Fully functioning kubernetes cluster inside docker
2. Keptn installed into the `keptn` namespace
3. The keptns UI (bridge) exposed to your local machine on port 80: `http://localhost`
4. [Job executor services](https://github.com/keptn-contrib/job-executor-service) installed in `keptn-jes` namespace
5. A web-based terminal exposed on port `7681`: `http://localhost:7681`




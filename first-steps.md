# First Steps After Installation

Head to the [keptn's bridge](http://localhost/bridge). Notice one project `helloworld` which has one stage `demo`. [Go to the sequence view](http://localhost/bridge/project/helloworld/sequence) for the project and click the sequence. the sequence has completed successfully and the log output is `Hello, world!`

![hello world sequence](assets/hello-world-sequence.jpg)

During installation you provided a Git upstream repo. This is used as the "backing storage" for keptn. Everything change is recorded in this Git upstream.

The installer created a keptn project which is defined in the `shipyard.yaml` file stored in the `main` branch of the upstream. A shipyard file defines your environment ([more details here](https://keptn.sh/docs/{{ .site.keptn_docs_version }}/manage/shipyard/)). The shipyard also defines the available sequences and tasks that will execute. Right now there is only one stage: `demo` with one sequence: `hello` and that sequence has only one task: `hello-world`.

Keptn creates

> Note: Stages cannot currently be added, removed or renamed after project creation. This is a [known limitation](https://github.com/keptn/enhancement-proposals/pull/70).

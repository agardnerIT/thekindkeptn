FROM alpine:3.15.0

RUN apk add --no-cache \
    bash \
    curl \
    docker \
	openssl
    wget

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Kubernetes in Docker (kind)
RUN curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install Keptn CLI
RUN wget https://github.com/keptn/keptn/releases/download/0.12.0/keptn-0.12.0-linux-amd64.tar.gz && \
    tar -xf keptn-0.12.0-linux-amd64.tar.gz && \
	cp keptn-0.12.0-linux-amd64 /usr/local/bin/keptn

COPY install_script.sh /
COPY kind.yaml /root/

ENV PATH="${PATH}:/root"

ENTRYPOINT ["/bin/bash", "/install_script.sh"]

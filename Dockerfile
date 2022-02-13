FROM debian:buster-slim

RUN apt update

# Remove any old docker install: prep for docker install
# Docker will be installed during install_script.sh
RUN apt-get remove -y \
    docker \
	docker.io \
	runc
	
# Install useful packages including docker
RUN apt install -y \
    curl \
    git \
	openssl \
    jq \
    wget \
	sudo \
	apt-transport-https \
	ca-certificates \
	gnupg2 \
	software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt update

RUN apt install -y \
    docker-ce \
	docker-ce-cli \
	containerd.io

RUN curl -sL https://get.keptn.sh | KEPTN_VERSION=0.12.0 bash

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

COPY install_script.sh /
COPY kind.yaml /root/

ENV PATH="${PATH}:/root"

ENTRYPOINT ["/bin/bash", "/install_script.sh"]

FROM rancher/k3d:5.3.0-dind

ARG KEPTN_VERSION=0.16.0
ARG TTYD_VERSION=1.6.3

COPY install_script.sh /
COPY k3dconfig.yaml /root/

# Install ttyd web terminal
RUN wget https://github.com/tsl0922/ttyd/releases/download/$TTYD_VERSION/ttyd.x86_64 && mv ttyd.x86_64 /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install Keptn CLI
RUN wget https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION-linux-amd64.tar.gz && \
    tar -xf keptn-$KEPTN_VERSION-linux-amd64.tar.gz && \
	cp keptn-$KEPTN_VERSION-linux-amd64 /usr/local/bin/keptn

ENV PATH="${PATH}:/root"

ENTRYPOINT ["/bin/bash", "/install_script.sh"]

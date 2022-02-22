FROM rancher/k3d:5.2.2-dind

COPY install_script.sh /
COPY k3dconfig.yaml /root/

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install Keptn CLI
RUN wget https://github.com/keptn/keptn/releases/download/0.12.0/keptn-0.12.0-linux-amd64.tar.gz && \
    tar -xf keptn-0.12.0-linux-amd64.tar.gz && \
	cp keptn-0.12.0-linux-amd64 /usr/local/bin/keptn

ENV PATH="${PATH}:/root"

ENTRYPOINT ["/bin/bash", "/install_script.sh"]
#ENTRYPOINT ["/bin/bash"]

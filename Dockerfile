# syntax=docker/dockerfile:1.24
FROM quay.io/operator-framework/helm-operator:v1.42.2

# Update system packages to fix vulnerabilities
USER root
RUN microdnf upgrade -y && \
    microdnf clean all

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
COPY helm-charts  /helm-charts 
COPY LICENSE /licenses/
WORKDIR ${HOME}

USER 1001

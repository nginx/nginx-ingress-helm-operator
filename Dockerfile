# syntax=docker/dockerfile:1.24
FROM quay.io/operator-framework/helm-operator:v1.42.2

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}

COPY LICENSE /licenses/

# syntax=docker/dockerfile:1.20
FROM quay.io/operator-framework/helm-operator:v1.42.0

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}

COPY LICENSE /licenses/

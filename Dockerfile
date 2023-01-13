FROM quay.io/operator-framework/helm-operator:v1.26.0

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}

COPY LICENSE /licenses/

# hack to update packages with CVEs
USER root
RUN microdnf --nodocs upgrade -y libtasn1 sqlite-libs systemd-libs
USER 1001

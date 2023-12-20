# NginxIngress Custom Resource

The `NginxIngress` Custom Resource is the definition of a deployment of the Ingress Controller.
With this Custom Resource, the NGINX Ingress Operator will be able to deploy and configure instances of the Ingress Controller in your cluster.

## Configuration

There are several fields to configure the deployment of an Ingress Controller.

 The following example shows the usage of all fields (required and optional):

```yaml
apiVersion: charts.nginx.org/v1alpha1
kind: NginxIngress
metadata:
  name: nginxingress-sample
spec:
  # Default values copied from <project_dir>/helm-charts/nginx-ingress/values.yaml
  controller:
    name: controller
    kind: deployment
    selectorLabels: {}
    annotations: {}
    nginxplus: false
    nginxReloadTimeout: 60000
    appprotect:
      enable: false
      # logLevel: fatal
    appprotectdos:
      enable: false
      debug: false
      maxWorkers: 0
      maxDaemons: 0
      memory: 0
    hostNetwork: false
    hostPort:
      enable: false
      http: 80
      https: 443
    containerPort:
      http: 80
      https: 443
    dnsPolicy: ClusterFirst
    nginxDebug: false
    logLevel: 1
    customPorts: []
    image:
      repository: nginx/nginx-ingress
      tag: "3.4.0-ubi"
      # digest: "sha256:CHANGEME"
      pullPolicy: IfNotPresent
    lifecycle: {}
    customConfigMap: ""
    config:
      # name: nginx-config
      annotations: {}
      entries: {}
    defaultTLS:
      cert: ""
      key: ""
      secret: ""
    wildcardTLS:
      cert: ""
      key: ""
      secret: ""
    # nodeSelector: {}
    terminationGracePeriodSeconds: 30
    autoscaling:
      enabled: false
      annotations: {}
      minReplicas: 1
      maxReplicas: 3
      targetCPUUtilizationPercentage: 50
      targetMemoryUtilizationPercentage: 50
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
    # limits:
    #   cpu: 1
    #   memory: 1Gi
    tolerations: []
    affinity: {}
    # topologySpreadConstraints: {}
    env: []
    # - name: MY_VAR
    #   value: myvalue
    volumes: []
    # - name: extra-conf
    #   configMap:
    #     name: extra-conf
    volumeMounts: []
    # - name: extra-conf
    #   mountPath: /etc/nginx/conf.d/extra.conf
    #   subPath: extra.conf
    initContainers: []
    # - name: init-container
    #   image: busybox:1.34
    #   command: ['sh', '-c', 'echo this is initial setup!']
    minReadySeconds: 0
    podDisruptionBudget:
      enabled: false
      annotations: {}
      # minAvailable: 1
      # maxUnavailable: 1
    strategy: {}
    extraContainers: []
    # - name: container
    #   image: busybox:1.34
    #   command: ['sh', '-c', 'echo this is a sidecar!']
    replicaCount: 1
    ingressClass:
      name: nginx
      create: true
      setAsDefaultIngress: false
    watchNamespace: ""
    watchNamespaceLabel: ""
    watchSecretNamespace: ""
    enableCustomResources: true
    enablePreviewPolicies: false
    enableOIDC: false
    includeYear: false
    enableTLSPassthrough: false
    tlsPassthroughPort: 443
    enableCertManager: false
    enableExternalDNS: false
    globalConfiguration:
      create: false
      spec: {}
      # listeners:
      # - name: dns-udp
      #   port: 5353
      #   protocol: UDP
      # - name: dns-tcp
      #   port: 5353
      #   protocol: TCP
    enableSnippets: false
    healthStatus: false
    healthStatusURI: "/nginx-health"
    nginxStatus:
      enable: true
      port: 8080
      allowCidrs: "127.0.0.1"
    service:
      create: true
      type: LoadBalancer
      externalTrafficPolicy: Local
      annotations: {}
      extraLabels: {}
      loadBalancerIP: ""
      clusterIP: ""
      externalIPs: []
      loadBalancerSourceRanges: []
      # allocateLoadBalancerNodePorts: false
      # ipFamilyPolicy: SingleStack
      # ipFamilies:
      #   - IPv6
      httpPort:
        enable: true
        port: 80
        # nodePort: 80
        targetPort: 80
      httpsPort:
        enable: true
        port: 443
        # nodePort: 443
        targetPort: 443
      customPorts: []
    serviceAccount:
      annotations: {}
      # name: nginx-ingress
      imagePullSecretName: ""
    reportIngressStatus:
      enable: true
      # externalService: nginx-ingress
      ingressLink: ""
      enableLeaderElection: true
      # leaderElectionLockName: "nginx-ingress-leader-election"
      annotations: {}
    pod:
      annotations: {}
      extraLabels: {}
    # priorityClassName: ""
    readyStatus:
      enable: true
      port: 8081
      initialDelaySeconds: 0
    enableLatencyMetrics: false
    disableIPV6: false
    readOnlyRootFilesystem: false
  rbac:
    create: true
  prometheus:
    create: true
    port: 9113
    secret: ""
    scheme: http
    service:
      create: false
      labels:
        service: "nginx-ingress-prometheus-service"
    serviceMonitor:
      create: false
      labels: {}
      selectorMatchLabels:
        service: "nginx-ingress-prometheus-service"
      endpoints:
        - port: prometheus
  serviceInsight:
    create: false
    port: 9114
    secret: ""
    scheme: http
  nginxServiceMesh:
    enable: false
    enableEgress: false
 ```

For detailed documentation of individual parameters, please refer to the [Configuration](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/#configuration) section in our documentation on installing NGINX Ingress Controller with Helm.

## Notes
* The service account name cannot be overridden and needs to be set to `nginx-ingress`. This is a requirement due to the RBAC and SCC configuration on OpenShift clusters.
* The defaultServerSecret needs to be created before the IC deployment with the name of the secret supplied in the NginxIngress manifest, and cannot be created by instead supplying a cert and key.
* If required, the `controller.wildcardTLS.secret` must also be created separately with the name of the secret supplied in the NginxIngress manifest.

## Notes: Multiple NIC Deployments
* Please see [the NGINX Ingress Controller doumentation](https://docs.nginx.com/nginx-ingress-controller/installation/running-multiple-ingress-controllers/) for general information on running multiple NGINX Ingress Controllers in your cluster.
* To run multiple NIC instances deployed by the NGINX Ingress Operator in your cluster in the same namespace, `rbac.create` should be set to `false`, and the ServiceAccount and ClusterRoleBinding need to be created independently of the deployments. Please note that `controller.serviceAccount.imagePullSecretName` will also be ignored in this configuration, and will need to be configured as part of the independant ServiceAccount creation.
* The ClusterRoleBinding needs to configured to bind to the `nginx-ingress-operator-nginx-ingress-admin` ClusterRole.
* See [RBAC example spec](../resources/rbac-example.yaml) for an example ServiceAccount and ClusterRoleBinding manifest.
* To run multiple NIC instances deployed by the NGINX Ingress Operator in your cluster in any namespace but sharing an IngressClass, `controller.ingressClass` should be set to an empty string and the IngressClass resource needs to be created independantly of the deployments.Please note that `controller.setAsDefaultIngress` will also be ignored in this configuration, and will need to be configured as part of the independant IngressClass creation.
* See [IngressClass example spec](../resources/ingress-class.yaml) for an example IngressClass manifest.

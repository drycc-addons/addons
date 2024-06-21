<!--- app-name: Kvrocks; -->

# Kvrocks packaged by drycc

Apache Kvrocks is a distributed key value NoSQL database that uses RocksDB as storage engine and is compatible with kvrocks protocol. Kvrocks intends to decrease the cost of memory and increase the capacity while compared to kvrocks. The design of replication and storage was inspired by rocksplicator and blackwidow.

[Overview of Kvrocks;](https://kvrocks.apache.org/)

## Introduction

This chart bootstraps a [kvrocks](https://github.com/drycc-addons/addons/tree/main/addons/kvrocks/2.8) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


### Choose between Kvrocks; Helm Chart and Kvrocks; Cluster Helm Chart

You can choose any of the two Kvrocks; Helm charts for deploying a Kvrocks; cluster.

1. [Kvrocks; Helm Chart](https://github.com/drycc-addons/addons/tree/main/addons/kvrocks) will deploy a master-slave cluster, with the [option](https://github.com/drycc-addons/addons/tree/main/addons/kvrocks#sentinel-configuration-parameters) of enabling using Kvrocks; Sentinel.
2. [Kvrocks; Cluster Helm Chart](https://github.com/drycc-addons/addons/tree/main/addons/kvrocks) will deploy 

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release drycc-addons/kvrocks
```

The command deploys Kvrocks; on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                              | Value |
| ------------------------- | -------------------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                             | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array          | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)             | `""`  |
| `global.kvrocks.password`   | Global Kvrocks; password (overrides `auth.password`) | `""`  |


### Common parameters

| Name                     | Description                                                                             | Value           |
| ------------------------ | --------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`            | Override Kubernetes version                                                             | `""`            |
| `nameOverride`           | String to partially override common.names.fullname                                      | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname                                          | `""`            |
| `commonLabels`           | Labels to add to all deployed objects                                                   | `{}`            |
| `commonAnnotations`      | Annotations to add to all deployed objects                                              | `{}`            |
| `secretAnnotations`      | Annotations to add to secret                                                            | `{}`            |
| `clusterDomain`          | Kubernetes cluster domain name                                                          | `cluster.local` |
| `extraDeploy`            | Array of extra objects to deploy with the release                                       | `[]`            |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false`         |
| `diagnosticMode.command` | Command to override all containers in the deployment                                    | `["sleep"]`     |
| `diagnosticMode.args`    | Args to override all containers in the deployment                                       | `["infinity"]`  |


### Kvrocks; Image parameters

| Name                | Description                                             | Value                  |
| ------------------- | ------------------------------------------------------- | ---------------------- |
| `image.registry`    | Kvrocks; image registry                             | `docker.io`            |
| `image.repository`  | Kvrocks; image repository                           | `bitnami/kvrocks`        |
| `image.tag`         | Kvrocks; image tag (immutable tags are recommended) | `6.2.6-debian-10-r169` |
| `image.pullPolicy`  | Kvrocks; image pull policy                          | `IfNotPresent`         |
| `image.pullSecrets` | Kvrocks; image pull secrets                         | `[]`                   |
| `image.debug`       | Enable image debug mode                                 | `false`                |


### Kvrocks; common configuration parameters

| Name                             | Description                                                                             | Value         |
| -------------------------------- | --------------------------------------------------------------------------------------- | ------------- |
| `architecture`                   | Kvrocks; architecture. Allowed values: `standalone` or `replication`                | `replication` |
| `auth.enabled`                   | Enable password authentication                                                          | `true`        |
| `auth.sentinel`                  | Enable password authentication on sentinels too                                         | `true`        |
| `auth.password`                  | Kvrocks; password                                                                   | `""`          |
| `auth.existingSecret`            | The name of an existing secret with Kvrocks; credentials                            | `""`          |
| `auth.existingSecretPasswordKey` | Password key to be retrieved from existing secret                                       | `""`          |
| `commonConfiguration`            | Common configuration to be added into the ConfigMap                                     | `""`          |
| `existingConfigmap`              | The name of an existing ConfigMap with your custom configuration for Kvrocks; nodes | `""`          |


### Kvrocks; master configuration parameters

| Name                                        | Description                                                                                       | Value                    |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------ |
| `master.configuration`                      | Configuration for Kvrocks; master nodes                                                       | `""`                     |
| `master.disableCommands`                    | Array with Kvrocks; commands to disable on master nodes                                       | `["FLUSHDB","FLUSHALL"]` |
| `master.command`                            | Override default container command (useful when using custom images)                              | `[]`                     |
| `master.args`                               | Override default container args (useful when using custom images)                                 | `[]`                     |
| `master.preExecCmds`                        | Additional commands to run prior to starting Kvrocks; master                                  | `[]`                     |
| `master.extraFlags`                         | Array with additional command line flags for Kvrocks; master                                  | `[]`                     |
| `master.extraEnvVars`                       | Array with extra environment variables to add to Kvrocks; master nodes                        | `[]`                     |
| `master.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra env vars for Kvrocks; master nodes                | `""`                     |
| `master.extraEnvVarsSecret`                 | Name of existing Secret containing extra env vars for Kvrocks; master nodes                   | `""`                     |
| `master.containerPorts.kvrocks`               | Container port to open on Kvrocks; master nodes                                               | `6379`                   |
| `master.startupProbe.enabled`               | Enable startupProbe on Kvrocks; master nodes                                                  | `false`                  |
| `master.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                            | `20`                     |
| `master.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                                   | `5`                      |
| `master.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                                  | `5`                      |
| `master.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                                | `5`                      |
| `master.startupProbe.successThreshold`      | Success threshold for startupProbe                                                                | `1`                      |
| `master.livenessProbe.enabled`              | Enable livenessProbe on Kvrocks; master nodes                                                 | `true`                   |
| `master.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                                           | `20`                     |
| `master.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                                  | `5`                      |
| `master.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                                 | `5`                      |
| `master.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                               | `5`                      |
| `master.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                               | `1`                      |
| `master.readinessProbe.enabled`             | Enable readinessProbe on Kvrocks; master nodes                                                | `true`                   |
| `master.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                                          | `20`                     |
| `master.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                                 | `5`                      |
| `master.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                                | `1`                      |
| `master.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                              | `5`                      |
| `master.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                              | `1`                      |
| `master.customStartupProbe`                 | Custom startupProbe that overrides the default one                                                | `{}`                     |
| `master.customLivenessProbe`                | Custom livenessProbe that overrides the default one                                               | `{}`                     |
| `master.customReadinessProbe`               | Custom readinessProbe that overrides the default one                                              | `{}`                     |
| `master.resources.limits`                   | The resources limits for the Kvrocks; master containers                                       | `{}`                     |
| `master.resources.requests`                 | The requested resources for the Kvrocks; master containers                                    | `{}`                     |
| `master.podSecurityContext.enabled`         | Enabled Kvrocks; master pods' Security Context                                                | `true`                   |
| `master.podSecurityContext.fsGroup`         | Set Kvrocks; master pod's Security Context fsGroup                                            | `1001`                   |
| `master.containerSecurityContext.enabled`   | Enabled Kvrocks; master containers' Security Context                                          | `true`                   |
| `master.containerSecurityContext.runAsUser` | Set Kvrocks; master containers' Security Context runAsUser                                    | `1001`                   |
| `master.kind`                               | Use either Deployment or StatefulSet (default)                                                    | `StatefulSet`            |
| `master.schedulerName`                      | Alternate scheduler for Kvrocks; master pods                                                  | `""`                     |
| `master.updateStrategy.type`                | Kvrocks; master statefulset strategy type                                                     | `RollingUpdate`          |
| `master.priorityClassName`                  | Kvrocks; master pods' priorityClassName                                                       | `""`                     |
| `master.hostAliases`                        | Kvrocks; master pods host aliases                                                             | `[]`                     |
| `master.podLabels`                          | Extra labels for Kvrocks; master pods                                                         | `{}`                     |
| `master.podAnnotations`                     | Annotations for Kvrocks; master pods                                                          | `{}`                     |
| `master.shareProcessNamespace`              | Share a single process namespace between all of the containers in Kvrocks; master pods        | `false`                  |
| `master.podAffinityPreset`                  | Pod affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard`        | `""`                     |
| `master.podAntiAffinityPreset`              | Pod anti-affinity preset. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard`   | `soft`                   |
| `master.nodeAffinityPreset.type`            | Node affinity preset type. Ignored if `master.affinity` is set. Allowed values: `soft` or `hard`  | `""`                     |
| `master.nodeAffinityPreset.key`             | Node label key to match. Ignored if `master.affinity` is set                                      | `""`                     |
| `master.nodeAffinityPreset.values`          | Node label values to match. Ignored if `master.affinity` is set                                   | `[]`                     |
| `master.affinity`                           | Affinity for Kvrocks; master pods assignment                                                  | `{}`                     |
| `master.nodeSelector`                       | Node labels for Kvrocks; master pods assignment                                               | `{}`                     |
| `master.tolerations`                        | Tolerations for Kvrocks; master pods assignment                                               | `[]`                     |
| `master.topologySpreadConstraints`          | Spread Constraints for Kvrocks; master pod assignment                                         | `[]`                     |
| `master.dnsPolicy`                          | DNS Policy for Kvrocks; master pod                                                            | `""`                     |
| `master.dnsConfig`                          | DNS Configuration for Kvrocks; master pod                                                     | `{}`                     |
| `master.lifecycleHooks`                     | for the Kvrocks; master container(s) to automate configuration before or after startup        | `{}`                     |
| `master.extraVolumes`                       | Optionally specify extra list of additional volumes for the Kvrocks; master pod(s)            | `[]`                     |
| `master.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the Kvrocks; master container(s) | `[]`                     |
| `master.sidecars`                           | Add additional sidecar containers to the Kvrocks; master pod(s)                               | `[]`                     |
| `master.initContainers`                     | Add additional init containers to the Kvrocks; master pod(s)                                  | `[]`                     |
| `master.persistence.enabled`                | Enable persistence on Kvrocks; master nodes using Persistent Volume Claims                    | `true`                   |
| `master.persistence.medium`                 | Provide a medium for `emptyDir` volumes.                                                          | `""`                     |
| `master.persistence.sizeLimit`              | Set this to enable a size limit for `emptyDir` volumes.                                           | `""`                     |
| `master.persistence.path`                   | The path the volume will be mounted at on Kvrocks; master containers                          | `/data`                  |
| `master.persistence.subPath`                | The subdirectory of the volume to mount on Kvrocks; master containers                         | `""`                     |
| `master.persistence.storageClass`           | Persistent Volume storage class                                                                   | `""`                     |
| `master.persistence.accessModes`            | Persistent Volume access modes                                                                    | `["ReadWriteOnce"]`      |
| `master.persistence.size`                   | Persistent Volume size                                                                            | `8Gi`                    |
| `master.persistence.annotations`            | Additional custom annotations for the PVC                                                         | `{}`                     |
| `master.persistence.selector`               | Additional labels to match for the PVC                                                            | `{}`                     |
| `master.persistence.dataSource`             | Custom PVC data source                                                                            | `{}`                     |
| `master.persistence.existingClaim`          | Use a existing PVC which must be created manually before bound                                    | `""`                     |
| `master.service.type`                       | Kvrocks; master service type                                                                  | `ClusterIP`              |
| `master.service.ports.kvrocks`                | Kvrocks; master service port                                                                  | `6379`                   |
| `master.service.nodePorts.kvrocks`            | Node port for Kvrocks; master                                                                 | `""`                     |
| `master.service.externalTrafficPolicy`      | Kvrocks; master service external traffic policy                                               | `Cluster`                |
| `master.service.extraPorts`                 | Extra ports to expose (normally used with the `sidecar` value)                                    | `[]`                     |
| `master.service.clusterIP`                  | Kvrocks; master service Cluster IP                                                            | `""`                     |
| `master.service.loadBalancerIP`             | Kvrocks; master service Load Balancer IP                                                      | `""`                     |
| `master.service.loadBalancerSourceRanges`   | Kvrocks; master service Load Balancer sources                                                 | `[]`                     |
| `master.service.annotations`                | Additional custom annotations for Kvrocks; master service                                     | `{}`                     |
| `master.terminationGracePeriodSeconds`      | Integer setting the termination grace period for the kvrocks-master pods                            | `30`                     |


### Kvrocks; replicas configuration parameters

| Name                                         | Description                                                                                         | Value                    |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------ |
| `replica.replicaCount`                       | Number of Kvrocks; replicas to deploy                                                           | `3`                      |
| `replica.configuration`                      | Configuration for Kvrocks; replicas nodes                                                       | `""`                     |
| `replica.disableCommands`                    | Array with Kvrocks; commands to disable on replicas nodes                                       | `["FLUSHDB","FLUSHALL"]` |
| `replica.command`                            | Override default container command (useful when using custom images)                                | `[]`                     |
| `replica.args`                               | Override default container args (useful when using custom images)                                   | `[]`                     |
| `replica.preExecCmds`                        | Additional commands to run prior to starting Kvrocks; replicas                                  | `[]`                     |
| `replica.extraFlags`                         | Array with additional command line flags for Kvrocks; replicas                                  | `[]`                     |
| `replica.extraEnvVars`                       | Array with extra environment variables to add to Kvrocks; replicas nodes                        | `[]`                     |
| `replica.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra env vars for Kvrocks; replicas nodes                | `""`                     |
| `replica.extraEnvVarsSecret`                 | Name of existing Secret containing extra env vars for Kvrocks; replicas nodes                   | `""`                     |
| `replica.externalMaster.enabled`             | Use external master for bootstrapping                                                               | `false`                  |
| `replica.externalMaster.host`                | External master host to bootstrap from                                                              | `""`                     |
| `replica.externalMaster.port`                | Port for kvrocks service external master host                                                         | `6379`                   |
| `replica.containerPorts.kvrocks`               | Container port to open on Kvrocks; replicas nodes                                               | `6379`                   |
| `replica.startupProbe.enabled`               | Enable startupProbe on Kvrocks; replicas nodes                                                  | `true`                   |
| `replica.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                              | `10`                     |
| `replica.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                                     | `10`                     |
| `replica.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                                    | `5`                      |
| `replica.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                                  | `22`                     |
| `replica.startupProbe.successThreshold`      | Success threshold for startupProbe                                                                  | `1`                      |
| `replica.livenessProbe.enabled`              | Enable livenessProbe on Kvrocks; replicas nodes                                                 | `true`                   |
| `replica.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                                             | `20`                     |
| `replica.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                                    | `5`                      |
| `replica.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                                   | `5`                      |
| `replica.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                                 | `5`                      |
| `replica.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                                 | `1`                      |
| `replica.readinessProbe.enabled`             | Enable readinessProbe on Kvrocks; replicas nodes                                                | `true`                   |
| `replica.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                                            | `20`                     |
| `replica.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                                   | `5`                      |
| `replica.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                                  | `1`                      |
| `replica.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                                | `5`                      |
| `replica.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                                | `1`                      |
| `replica.customStartupProbe`                 | Custom startupProbe that overrides the default one                                                  | `{}`                     |
| `replica.customLivenessProbe`                | Custom livenessProbe that overrides the default one                                                 | `{}`                     |
| `replica.customReadinessProbe`               | Custom readinessProbe that overrides the default one                                                | `{}`                     |
| `replica.resources.limits`                   | The resources limits for the Kvrocks; replicas containers                                       | `{}`                     |
| `replica.resources.requests`                 | The requested resources for the Kvrocks; replicas containers                                    | `{}`                     |
| `replica.podSecurityContext.enabled`         | Enabled Kvrocks; replicas pods' Security Context                                                | `true`                   |
| `replica.podSecurityContext.fsGroup`         | Set Kvrocks; replicas pod's Security Context fsGroup                                            | `1001`                   |
| `replica.containerSecurityContext.enabled`   | Enabled Kvrocks; replicas containers' Security Context                                          | `true`                   |
| `replica.containerSecurityContext.runAsUser` | Set Kvrocks; replicas containers' Security Context runAsUser                                    | `1001`                   |
| `replica.schedulerName`                      | Alternate scheduler for Kvrocks; replicas pods                                                  | `""`                     |
| `replica.updateStrategy.type`                | Kvrocks; replicas statefulset strategy type                                                     | `RollingUpdate`          |
| `replica.priorityClassName`                  | Kvrocks; replicas pods' priorityClassName                                                       | `""`                     |
| `replica.podManagementPolicy`                | podManagementPolicy to manage scaling operation of %%MAIN_CONTAINER_NAME%% pods                     | `""`                     |
| `replica.hostAliases`                        | Kvrocks; replicas pods host aliases                                                             | `[]`                     |
| `replica.podLabels`                          | Extra labels for Kvrocks; replicas pods                                                         | `{}`                     |
| `replica.podAnnotations`                     | Annotations for Kvrocks; replicas pods                                                          | `{}`                     |
| `replica.shareProcessNamespace`              | Share a single process namespace between all of the containers in Kvrocks; replicas pods        | `false`                  |
| `replica.podAffinityPreset`                  | Pod affinity preset. Ignored if `replica.affinity` is set. Allowed values: `soft` or `hard`         | `""`                     |
| `replica.podAntiAffinityPreset`              | Pod anti-affinity preset. Ignored if `replica.affinity` is set. Allowed values: `soft` or `hard`    | `soft`                   |
| `replica.nodeAffinityPreset.type`            | Node affinity preset type. Ignored if `replica.affinity` is set. Allowed values: `soft` or `hard`   | `""`                     |
| `replica.nodeAffinityPreset.key`             | Node label key to match. Ignored if `replica.affinity` is set                                       | `""`                     |
| `replica.nodeAffinityPreset.values`          | Node label values to match. Ignored if `replica.affinity` is set                                    | `[]`                     |
| `replica.affinity`                           | Affinity for Kvrocks; replicas pods assignment                                                  | `{}`                     |
| `replica.nodeSelector`                       | Node labels for Kvrocks; replicas pods assignment                                               | `{}`                     |
| `replica.tolerations`                        | Tolerations for Kvrocks; replicas pods assignment                                               | `[]`                     |
| `replica.topologySpreadConstraints`          | Spread Constraints for Kvrocks; replicas pod assignment                                         | `[]`                     |
| `replica.dnsPolicy`                          | DNS Policy for Kvrocks; replica pods                                                            | `""`                     |
| `replica.dnsConfig`                          | DNS Configuration for Kvrocks; replica pods                                                     | `{}`                     |
| `replica.lifecycleHooks`                     | for the Kvrocks; replica container(s) to automate configuration before or after startup         | `{}`                     |
| `replica.extraVolumes`                       | Optionally specify extra list of additional volumes for the Kvrocks; replicas pod(s)            | `[]`                     |
| `replica.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the Kvrocks; replicas container(s) | `[]`                     |
| `replica.sidecars`                           | Add additional sidecar containers to the Kvrocks; replicas pod(s)                               | `[]`                     |
| `replica.initContainers`                     | Add additional init containers to the Kvrocks; replicas pod(s)                                  | `[]`                     |
| `replica.persistence.enabled`                | Enable persistence on Kvrocks; replicas nodes using Persistent Volume Claims                    | `true`                   |
| `replica.persistence.medium`                 | Provide a medium for `emptyDir` volumes.                                                            | `""`                     |
| `replica.persistence.path`                   | The path the volume will be mounted at on Kvrocks; replicas containers                          | `/data`                  |
| `replica.persistence.subPath`                | The subdirectory of the volume to mount on Kvrocks; replicas containers                         | `""`                     |
| `replica.persistence.storageClass`           | Persistent Volume storage class                                                                     | `""`                     |
| `replica.persistence.accessModes`            | Persistent Volume access modes                                                                      | `["ReadWriteOnce"]`      |
| `replica.persistence.size`                   | Persistent Volume size                                                                              | `8Gi`                    |
| `replica.persistence.annotations`            | Additional custom annotations for the PVC                                                           | `{}`                     |
| `replica.persistence.selector`               | Additional labels to match for the PVC                                                              | `{}`                     |
| `replica.persistence.dataSource`             | Custom PVC data source                                                                              | `{}`                     |
| `replica.service.type`                       | Kvrocks; replicas service type                                                                  | `ClusterIP`              |
| `replica.service.ports.kvrocks`                | Kvrocks; replicas service port                                                                  | `6379`                   |
| `replica.service.nodePorts.kvrocks`            | Node port for Kvrocks; replicas                                                                 | `""`                     |
| `replica.service.externalTrafficPolicy`      | Kvrocks; replicas service external traffic policy                                               | `Cluster`                |
| `replica.service.extraPorts`                 | Extra ports to expose (normally used with the `sidecar` value)                                      | `[]`                     |
| `replica.service.clusterIP`                  | Kvrocks; replicas service Cluster IP                                                            | `""`                     |
| `replica.service.loadBalancerIP`             | Kvrocks; replicas service Load Balancer IP                                                      | `""`                     |
| `replica.service.loadBalancerSourceRanges`   | Kvrocks; replicas service Load Balancer sources                                                 | `[]`                     |
| `replica.service.annotations`                | Additional custom annotations for Kvrocks; replicas service                                     | `{}`                     |
| `replica.terminationGracePeriodSeconds`      | Integer setting the termination grace period for the kvrocks-replicas pods                            | `30`                     |
| `replica.autoscaling.enabled`                | Enable replica autoscaling settings                                                                 | `false`                  |
| `replica.autoscaling.minReplicas`            | Minimum replicas for the pod autoscaling                                                            | `1`                      |
| `replica.autoscaling.maxReplicas`            | Maximum replicas for the pod autoscaling                                                            | `11`                     |
| `replica.autoscaling.targetCPU`              | Percentage of CPU to consider when autoscaling                                                      | `""`                     |
| `replica.autoscaling.targetMemory`           | Percentage of Memory to consider when autoscaling                                                   | `""`                     |


### Kvrocks with Sentinel configuration parameters

| Name                                          | Description                                                                                                                                 | Value                    |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `sentinel.enabled`                            | Use Kvrocks; Sentinel on Kvrocks; pods.                                                                                             | `false`                  |
| `sentinel.image.registry`                     | Kvrocks; Sentinel image registry                                                                                                        | `docker.io`              |
| `sentinel.image.repository`                   | Kvrocks; Sentinel image repository                                                                                                      | `bitnami/sentinel` |
| `sentinel.image.tag`                          | Kvrocks; Sentinel image tag (immutable tags are recommended)                                                                            | `6.2.6-debian-10-r167`   |
| `sentinel.image.pullPolicy`                   | Kvrocks; Sentinel image pull policy                                                                                                     | `IfNotPresent`           |
| `sentinel.image.pullSecrets`                  | Kvrocks; Sentinel image pull secrets                                                                                                    | `[]`                     |
| `sentinel.image.debug`                        | Enable image debug mode                                                                                                                     | `false`                  |
| `sentinel.masterSet`                          | Master set name                                                                                                                             | `mymaster`               |
| `sentinel.quorum`                             | Sentinel Quorum                                                                                                                             | `2`                      |
| `sentinel.getMasterTimeout`                   | Amount of time to allow before get_sentinel_master_info() times out.                                                                        | `220`                    |
| `sentinel.automateClusterRecovery`            | Automate cluster recovery in cases where the last replica is not considered a good replica and Sentinel won't automatically failover to it. | `false`                  |
| `sentinel.downAfterMilliseconds`              | Timeout for detecting a Kvrocks; node is down                                                                                           | `60000`                  |
| `sentinel.failoverTimeout`                    | Timeout for performing a election failover                                                                                                  | `18000`                  |
| `sentinel.parallelSyncs`                      | Number of replicas that can be reconfigured in parallel to use the new master after a failover                                              | `1`                      |
| `sentinel.configuration`                      | Configuration for Kvrocks; Sentinel nodes                                                                                               | `""`                     |
| `sentinel.command`                            | Override default container command (useful when using custom images)                                                                        | `[]`                     |
| `sentinel.args`                               | Override default container args (useful when using custom images)                                                                           | `[]`                     |
| `sentinel.preExecCmds`                        | Additional commands to run prior to starting Kvrocks; Sentinel                                                                          | `[]`                     |
| `sentinel.extraEnvVars`                       | Array with extra environment variables to add to Kvrocks; Sentinel nodes                                                                | `[]`                     |
| `sentinel.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra env vars for Kvrocks; Sentinel nodes                                                        | `""`                     |
| `sentinel.extraEnvVarsSecret`                 | Name of existing Secret containing extra env vars for Kvrocks; Sentinel nodes                                                           | `""`                     |
| `sentinel.externalMaster.enabled`             | Use external master for bootstrapping                                                                                                       | `false`                  |
| `sentinel.externalMaster.host`                | External master host to bootstrap from                                                                                                      | `""`                     |
| `sentinel.externalMaster.port`                | Port for kvrocks service external master host                                                                                                 | `6379`                   |
| `sentinel.containerPorts.sentinel`            | Container port to open on Kvrocks; Sentinel nodes                                                                                       | `26379`                  |
| `sentinel.startupProbe.enabled`               | Enable startupProbe on Kvrocks; Sentinel nodes                                                                                          | `true`                   |
| `sentinel.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                                                                      | `10`                     |
| `sentinel.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                                                                             | `10`                     |
| `sentinel.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                                                                            | `5`                      |
| `sentinel.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                                                                          | `22`                     |
| `sentinel.startupProbe.successThreshold`      | Success threshold for startupProbe                                                                                                          | `1`                      |
| `sentinel.livenessProbe.enabled`              | Enable livenessProbe on Kvrocks; Sentinel nodes                                                                                         | `true`                   |
| `sentinel.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                                                                                     | `20`                     |
| `sentinel.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                                                                            | `5`                      |
| `sentinel.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                                                                           | `5`                      |
| `sentinel.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                                                                         | `5`                      |
| `sentinel.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                                                                         | `1`                      |
| `sentinel.readinessProbe.enabled`             | Enable readinessProbe on Kvrocks; Sentinel nodes                                                                                        | `true`                   |
| `sentinel.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                                                                                    | `20`                     |
| `sentinel.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                                                                           | `5`                      |
| `sentinel.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                                                                          | `1`                      |
| `sentinel.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                                                                        | `5`                      |
| `sentinel.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                                                                        | `1`                      |
| `sentinel.customStartupProbe`                 | Custom startupProbe that overrides the default one                                                                                          | `{}`                     |
| `sentinel.customLivenessProbe`                | Custom livenessProbe that overrides the default one                                                                                         | `{}`                     |
| `sentinel.customReadinessProbe`               | Custom readinessProbe that overrides the default one                                                                                        | `{}`                     |
| `sentinel.persistence.enabled`                | Enable persistence on Kvrocks; sentinel nodes using Persistent Volume Claims (Experimental)                                             | `false`                  |
| `sentinel.persistence.storageClass`           | Persistent Volume storage class                                                                                                             | `""`                     |
| `sentinel.persistence.accessModes`            | Persistent Volume access modes                                                                                                              | `["ReadWriteOnce"]`      |
| `sentinel.persistence.size`                   | Persistent Volume size                                                                                                                      | `100Mi`                  |
| `sentinel.persistence.annotations`            | Additional custom annotations for the PVC                                                                                                   | `{}`                     |
| `sentinel.persistence.selector`               | Additional labels to match for the PVC                                                                                                      | `{}`                     |
| `sentinel.persistence.dataSource`             | Custom PVC data source                                                                                                                      | `{}`                     |
| `sentinel.resources.limits`                   | The resources limits for the Kvrocks; Sentinel containers                                                                               | `{}`                     |
| `sentinel.resources.requests`                 | The requested resources for the Kvrocks; Sentinel containers                                                                            | `{}`                     |
| `sentinel.containerSecurityContext.enabled`   | Enabled Kvrocks; Sentinel containers' Security Context                                                                                  | `true`                   |
| `sentinel.containerSecurityContext.runAsUser` | Set Kvrocks; Sentinel containers' Security Context runAsUser                                                                            | `1001`                   |
| `sentinel.lifecycleHooks`                     | for the Kvrocks; sentinel container(s) to automate configuration before or after startup                                                | `{}`                     |
| `sentinel.extraVolumes`                       | Optionally specify extra list of additional volumes for the Kvrocks; Sentinel                                                           | `[]`                     |
| `sentinel.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the Kvrocks; Sentinel container(s)                                         | `[]`                     |
| `sentinel.service.type`                       | Kvrocks; Sentinel service type                                                                                                          | `ClusterIP`              |
| `sentinel.service.ports.kvrocks`                | Kvrocks; service port for Kvrocks;                                                                                                  | `6379`                   |
| `sentinel.service.ports.sentinel`             | Kvrocks; service port for Kvrocks; Sentinel                                                                                         | `26379`                  |
| `sentinel.service.nodePorts.kvrocks`            | Node port for Kvrocks;                                                                                                                  | `""`                     |
| `sentinel.service.nodePorts.sentinel`         | Node port for Sentinel                                                                                                                      | `""`                     |
| `sentinel.service.externalTrafficPolicy`      | Kvrocks; Sentinel service external traffic policy                                                                                       | `Cluster`                |
| `sentinel.service.extraPorts`                 | Extra ports to expose (normally used with the `sidecar` value)                                                                              | `[]`                     |
| `sentinel.service.clusterIP`                  | Kvrocks; Sentinel service Cluster IP                                                                                                    | `""`                     |
| `sentinel.service.loadBalancerIP`             | Kvrocks; Sentinel service Load Balancer IP                                                                                              | `""`                     |
| `sentinel.service.loadBalancerSourceRanges`   | Kvrocks; Sentinel service Load Balancer sources                                                                                         | `[]`                     |
| `sentinel.service.annotations`                | Additional custom annotations for Kvrocks; Sentinel service                                                                             | `{}`                     |
| `sentinel.terminationGracePeriodSeconds`      | Integer setting the termination grace period for the kvrocks-node pods                                                                        | `30`                     |


### Other Parameters

| Name                                          | Description                                                                                                                                 | Value   |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `networkPolicy.enabled`                       | Enable creation of NetworkPolicy resources                                                                                                  | `false` |
| `networkPolicy.allowExternal`                 | Don't require client label for connections                                                                                                  | `true`  |
| `networkPolicy.extraIngress`                  | Add extra ingress rules to the NetworkPolicy                                                                                                | `[]`    |
| `networkPolicy.extraEgress`                   | Add extra egress rules to the NetworkPolicy                                                                                                 | `[]`    |
| `networkPolicy.ingressNSMatchLabels`          | Labels to match to allow traffic from other namespaces                                                                                      | `{}`    |
| `networkPolicy.ingressNSPodMatchLabels`       | Pod labels to match to allow traffic from other namespaces                                                                                  | `{}`    |
| `podSecurityPolicy.create`                    | Whether to create a PodSecurityPolicy. WARNING: PodSecurityPolicy is deprecated in Kubernetes v1.21 or later, unavailable in v1.25 or later | `false` |
| `podSecurityPolicy.enabled`                   | Enable PodSecurityPolicy's RBAC rules                                                                                                       | `false` |
| `rbac.create`                                 | Specifies whether RBAC resources should be created                                                                                          | `false` |
| `rbac.rules`                                  | Custom RBAC rules to set                                                                                                                    | `[]`    |
| `serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                                                                                        | `true`  |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                                                                                                      | `""`    |
| `serviceAccount.automountServiceAccountToken` | Whether to auto mount the service account token                                                                                             | `true`  |
| `serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                                                                                        | `{}`    |
| `pdb.create`                                  | Specifies whether a PodDisruptionBudget should be created                                                                                   | `false` |
| `pdb.minAvailable`                            | Min number of pods that must still be available after the eviction                                                                          | `1`     |
| `pdb.maxUnavailable`                          | Max number of pods that can be unavailable after the eviction                                                                               | `""`    |


### Metrics Parameters

| Name                                         | Description                                                                                      | Value                    |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------ |
| `metrics.enabled`                            | Start a sidecar prometheus exporter to expose Kvrocks; metrics                               | `false`                  |
| `metrics.image.registry`                     | Kvrocks; Exporter image registry                                                             | `docker.io`              |
| `metrics.image.repository`                   | Kvrocks; Exporter image repository                                                           | `bitnami/kvrocks-exporter` |
| `metrics.image.tag`                          | Kvrocks; Kvrocks; Exporter image tag (immutable tags are recommended)                    | `1.37.0-debian-10-r9`    |
| `metrics.image.pullPolicy`                   | Kvrocks; Exporter image pull policy                                                          | `IfNotPresent`           |
| `metrics.image.pullSecrets`                  | Kvrocks; Exporter image pull secrets                                                         | `[]`                     |
| `metrics.command`                            | Override default metrics container init command (useful when using custom images)                | `[]`                     |
| `metrics.kvrocksTargetHost`                    | A way to specify an alternative Kvrocks; hostname                                            | `localhost`              |
| `metrics.extraArgs`                          | Extra arguments for Kvrocks; exporter, for example:                                          | `{}`                     |
| `metrics.extraEnvVars`                       | Array with extra environment variables to add to Kvrocks; exporter                           | `[]`                     |
| `metrics.containerSecurityContext.enabled`   | Enabled Kvrocks; exporter containers' Security Context                                       | `true`                   |
| `metrics.containerSecurityContext.runAsUser` | Set Kvrocks; exporter containers' Security Context runAsUser                                 | `1001`                   |
| `metrics.extraVolumes`                       | Optionally specify extra list of additional volumes for the Kvrocks; metrics sidecar         | `[]`                     |
| `metrics.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the Kvrocks; metrics sidecar    | `[]`                     |
| `metrics.resources.limits`                   | The resources limits for the Kvrocks; exporter container                                     | `{}`                     |
| `metrics.resources.requests`                 | The requested resources for the Kvrocks; exporter container                                  | `{}`                     |
| `metrics.podLabels`                          | Extra labels for Kvrocks; exporter pods                                                      | `{}`                     |
| `metrics.podAnnotations`                     | Annotations for Kvrocks; exporter pods                                                       | `{}`                     |
| `metrics.service.type`                       | Kvrocks; exporter service type                                                               | `ClusterIP`              |
| `metrics.service.port`                       | Kvrocks; exporter service port                                                               | `9121`                   |
| `metrics.service.externalTrafficPolicy`      | Kvrocks; exporter service external traffic policy                                            | `Cluster`                |
| `metrics.service.extraPorts`                 | Extra ports to expose (normally used with the `sidecar` value)                                   | `[]`                     |
| `metrics.service.loadBalancerIP`             | Kvrocks; exporter service Load Balancer IP                                                   | `""`                     |
| `metrics.service.loadBalancerSourceRanges`   | Kvrocks; exporter service Load Balancer sources                                              | `[]`                     |
| `metrics.service.annotations`                | Additional custom annotations for Kvrocks; exporter service                                  | `{}`                     |
| `metrics.serviceMonitor.enabled`             | Create ServiceMonitor resource(s) for scraping metrics using PrometheusOperator                  | `false`                  |
| `metrics.serviceMonitor.namespace`           | The namespace in which the ServiceMonitor will be created                                        | `""`                     |
| `metrics.serviceMonitor.interval`            | The interval at which metrics should be scraped                                                  | `30s`                    |
| `metrics.serviceMonitor.scrapeTimeout`       | The timeout after which the scrape is ended                                                      | `""`                     |
| `metrics.serviceMonitor.relabellings`        | Metrics RelabelConfigs to apply to samples before scraping.                                      | `[]`                     |
| `metrics.serviceMonitor.metricRelabelings`   | Metrics RelabelConfigs to apply to samples before ingestion.                                     | `[]`                     |
| `metrics.serviceMonitor.honorLabels`         | Specify honorLabels parameter to add the scrape endpoint                                         | `false`                  |
| `metrics.serviceMonitor.additionalLabels`    | Additional labels that can be used so ServiceMonitor resource(s) can be discovered by Prometheus | `{}`                     |
| `metrics.prometheusRule.enabled`             | Create a custom prometheusRule Resource for scraping metrics using PrometheusOperator            | `false`                  |
| `metrics.prometheusRule.namespace`           | The namespace in which the prometheusRule will be created                                        | `""`                     |
| `metrics.prometheusRule.additionalLabels`    | Additional labels for the prometheusRule                                                         | `{}`                     |
| `metrics.prometheusRule.rules`               | Custom Prometheus rules                                                                          | `[]`                     |


### Init Container Parameters

| Name                                                   | Description                                                                                     | Value                   |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | ----------------------- |
| `volumePermissions.enabled`                            | Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup` | `false`                 |
| `volumePermissions.image.registry`                     | Bitnami Shell image registry                                                                    | `docker.io`             |
| `volumePermissions.image.repository`                   | Bitnami Shell image repository                                                                  | `bitnami/bitnami-shell` |
| `volumePermissions.image.tag`                          | Bitnami Shell image tag (immutable tags are recommended)                                        | `10-debian-10-r378`     |
| `volumePermissions.image.pullPolicy`                   | Bitnami Shell image pull policy                                                                 | `IfNotPresent`          |
| `volumePermissions.image.pullSecrets`                  | Bitnami Shell image pull secrets                                                                | `[]`                    |
| `volumePermissions.resources.limits`                   | The resources limits for the init container                                                     | `{}`                    |
| `volumePermissions.resources.requests`                 | The requested resources for the init container                                                  | `{}`                    |
| `volumePermissions.containerSecurityContext.runAsUser` | Set init container's Security Context runAsUser                                                 | `0`                     |
| `sysctl.enabled`                                       | Enable init container to modify Kernel settings                                                 | `false`                 |
| `sysctl.image.registry`                                | Bitnami Shell image registry                                                                    | `docker.io`             |
| `sysctl.image.repository`                              | Bitnami Shell image repository                                                                  | `bitnami/bitnami-shell` |
| `sysctl.image.tag`                                     | Bitnami Shell image tag (immutable tags are recommended)                                        | `10-debian-10-r378`     |
| `sysctl.image.pullPolicy`                              | Bitnami Shell image pull policy                                                                 | `IfNotPresent`          |
| `sysctl.image.pullSecrets`                             | Bitnami Shell image pull secrets                                                                | `[]`                    |
| `sysctl.command`                                       | Override default init-sysctl container command (useful when using custom images)                | `[]`                    |
| `sysctl.mountHostSys`                                  | Mount the host `/sys` folder to `/host-sys`                                                     | `false`                 |
| `sysctl.resources.limits`                              | The resources limits for the init container                                                     | `{}`                    |
| `sysctl.resources.requests`                            | The requested resources for the init container                                                  | `{}`                    |


### useExternalDNS Parameters

| Name                                   | Description                                                                                                                              | Value                               |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `useExternalDNS.enabled`               | Enable various syntax that would enable external-dns to work.  Note this requires a working installation of `external-dns` to be usable. | `false`                             |
| `useExternalDNS.additionalAnnotations` | Extra annotations to be utilized when `external-dns` is enabled.                                                                         | `{}`                                |
| `useExternalDNS.annotationKey`         | The annotation key utilized when `external-dns` is enabled.                                                                              | `external-dns.alpha.kubernetes.io/` |
| `useExternalDNS.suffix`                | The DNS suffix utilized when `external-dns` is enabled.  Note that we prepend the suffix with the full name of the release.              | `""`                                |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set auth.password=secretpassword \
    bitnami/kvrocks
```

The above command sets the Kvrocks; server password to `secretpassword`.

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml bitnami/kvrocks
```

> **Tip**: You can use the default [values.yaml](values.yaml)

#### Default: Master-Replicas

When installing the chart with `architecture=replication`, it will deploy a Kvrocks; master StatefulSet (only one master node allowed) and a Kvrocks; replicas StatefulSet. The replicas will be read-replicas of the master. Two services will be exposed:

- Kvrocks; Master service: Points to the master, where read-write operations can be performed
- Kvrocks; Replicas service: Points to the replicas, where only read operations are allowed.

In case the master crashes, the replicas will wait until the master node is respawned again by the Kubernetes Controller Manager.

#### Standalone

When installing the chart with `architecture=standalone`, it will deploy a standalone Kvrocks; StatefulSet (only one node allowed). A single service will be exposed:

- Kvrocks; Master service: Points to the master, where read-write operations can be performed

#### Master-Replicas with Sentinel

When installing the chart with `architecture=replication` and `sentinel.enabled=true`, it will deploy a Kvrocks; master StatefulSet (only one master allowed) and a Kvrocks; replicas StatefulSet. In this case, the pods will contain an extra container with Kvrocks; Sentinel. This container will form a cluster of Kvrocks; Sentinel nodes, which will promote a new master in case the actual one fails. In addition to this, only one service is exposed:

- Kvrocks; service: Exposes port 6379 for Kvrocks; read-only operations and port 26379 for accessing Kvrocks; Sentinel.

For read-only operations, access the service using port 6379. For write operations, it's necessary to access the Kvrocks; Sentinel cluster and query the current master using the command below (using redis-cli or similar):

```
SENTINEL get-master-addr-by-name <name of your MasterSet. e.g: mymaster>
```

This command will return the address of the current master, which can be accessed from inside the cluster.

In case the current master crashes, the Sentinel containers will elect a new master node.

### Metrics

The chart optionally can start a metrics exporter for [prometheus](https://prometheus.io). The metrics endpoint (port 9121) is exposed in the service. Metrics can be scraped from within the cluster using something similar as the described in the [example Prometheus scrape configuration](https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml). If metrics are to be scraped from outside the cluster, the Kubernetes API proxy can be utilized to access the endpoint.

### Host Kernel Settings

Kvrocks; may require some changes in the kernel of the host machine to work as expected, in particular increasing the `somaxconn` value and disabling transparent huge pages.

Refer to the chart documentation for more information on [configuring host kernel settings with an example](https://docs.bitnami.com/kubernetes/infrastructure/kvrocks/administration/configure-kernel-settings/).

## Persistence

By default, the chart mounts a [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) at the `/data` path. The volume is created using dynamic volume provisioning. If a Persistent Volume Claim already exists, specify it during installation.

### Existing PersistentVolumeClaim

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart

```bash
$ helm install my-release --set master.persistence.existingClaim=PVC_NAME bitnami/kvrocks
```

## Backup and restore

Refer to the chart documentation for more information on [backing up and restoring Kvrocks; deployments](https://docs.bitnami.com/kubernetes/infrastructure/kvrocks/administration/backup-restore/).

## NetworkPolicy

To enable network policy for Kvrocks;, install [a networking plugin that implements the Kubernetes NetworkPolicy spec](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy#before-you-begin), and set `networkPolicy.enabled` to `true`.

Refer to the chart documenation for more information on [enabling the network policy in Kvrocks; deployments](https://docs.bitnami.com/kubernetes/infrastructure/kvrocks/administration/enable-network-policy/).

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `XXX.affinity` parameter(s). Find more information about Pod's affinity in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinities) chart. To do so, set the `XXX.podAffinityPreset`, `XXX.podAntiAffinityPreset`, or `XXX.nodeAffinityPreset` parameters.
{{/*
Copyright Drycc Community.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the prometheus scrape configuration for kubernetes objects.
Usage:
{{ include "prometheus.scrape_config" (dict "component" "alertmanager" "context" $) }}
*/}}
{{- define "prometheus.scrape_config" -}}
kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      own_namespace: true
      names:
      - {{ include "common.names.namespace" .context }}
metrics_path: /metrics
relabel_configs:
  - source_labels:
      - job
    target_label: __tmp_prometheus_job_name
  - action: keep
    source_labels:
      - __meta_kubernetes_service_label_app_kubernetes_io_component
      - __meta_kubernetes_service_labelpresent_app_kubernetes_io_component
    regex: ({{ .component }});true
  - action: keep
    source_labels:
      - __meta_kubernetes_service_label_app_kubernetes_io_instance
      - __meta_kubernetes_service_labelpresent_app_kubernetes_io_instance
    regex: ({{ .context.Release.Name }});true
  - action: keep
    source_labels:
      - __meta_kubernetes_service_label_app_kubernetes_io_name
      - __meta_kubernetes_service_labelpresent_app_kubernetes_io_name
    regex: (prometheus);true
  - action: keep
    source_labels:
      - __meta_kubernetes_endpoint_port_name
    regex: http
  - source_labels:
      - __meta_kubernetes_endpoint_address_target_kind
      - __meta_kubernetes_endpoint_address_target_name
    separator: ;
    regex: Node;(.*)
    replacement: ${1}
    target_label: node
  - source_labels:
      - __meta_kubernetes_endpoint_address_target_kind
      - __meta_kubernetes_endpoint_address_target_name
    separator: ;
    regex: Pod;(.*)
    replacement: ${1}
    target_label: pod
  - source_labels:
      - __meta_kubernetes_namespace
    target_label: namespace
  - source_labels:
      - __meta_kubernetes_service_name
    target_label: service
  - source_labels:
      - __meta_kubernetes_pod_name
    target_label: pod
  - source_labels:
      - __meta_kubernetes_pod_container_name
    target_label: container
  - action: drop
    source_labels:
      - __meta_kubernetes_pod_phase
    regex: (Failed|Succeeded)
  - source_labels:
      - __meta_kubernetes_service_name
    target_label: job
    replacement: ${1}
  - target_label: endpoint
    replacement: http
  - source_labels:
      - __address__
    target_label: __tmp_hash
    modulus: 1
    action: hashmod
  - source_labels:
      - __tmp_hash
    regex: 0
    action: keep
{{- end -}}

{{- define "addons.ds_scrape_config" -}}
honor_labels: true
kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      own_namespace: true
      names:
      - {{ include "common.names.namespace" .context }}
relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape_slow]
    action: drop
    regex: true
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
    action: replace
    target_label: __scheme__
    regex: (https?)
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
    action: replace
    target_label: __metrics_path__
    regex: (.+)
  - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
    action: replace
    target_label: __address__
    regex: (.+?)(?::\d+)?;(\d+)
    replacement: $1:$2
  - action: labelmap
    regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
  - action: labelmap
    regex: __meta_kubernetes_service_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: service
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: node
{{- end -}}

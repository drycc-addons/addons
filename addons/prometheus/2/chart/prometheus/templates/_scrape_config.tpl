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

{{- define "addons.kubernetes-service-endpoints" -}}
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
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: service
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: node
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_name]
    separator: ; 
    regex: mysql
    action: drop
{{- end -}}

{{- define "addons.kubernetes-service-endpoints-slow" -}}
honor_labels: true
scrape_interval: 5m
scrape_timeout: 30s
kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      own_namespace: true
      names: 
      - {{ include "common.names.namespace" .context }}
relabel_configs:
  - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape_slow]
    action: keep
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
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_name]
    separator: ; 
    regex: mysql
    action: drop
{{- end -}}

{{- define "addons.kubernetes-pods" -}}
honor_labels: true
kubernetes_sd_configs:
  - role: pod
    namespaces:
      own_namespace: true
      names: 
      - {{ include "common.names.namespace" .context }}

relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape_slow]
    action: drop
    regex: true
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
    action: replace
    regex: (https?)
    target_label: __scheme__
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
    action: replace
    target_label: __metrics_path__
    regex: (.+)
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    action: replace
    regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
    replacement: '[$2]:$1'
    target_label: __address__
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    action: replace
    regex: (\d+);((([0-9]+?)(\.|$)){4})
    replacement: $2:$1
    target_label: __address__
  - action: labelmap
    regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_pod_name]
    action: replace
    target_label: pod
  - source_labels: [__meta_kubernetes_pod_phase]
    regex: Pending|Succeeded|Failed|Completed
    action: drop
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: node
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_name]
    separator: ; 
    regex: mysql
    action: drop
{{- end -}}

{{- define "addons.kubernetes-pods-slow" -}}
honor_labels: true
scrape_interval: 5m
scrape_timeout: 30s
kubernetes_sd_configs:
  - role: pod
    namespaces:
      own_namespace: true
      names: 
      - {{ include "common.names.namespace" .context }}

relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape_slow]
    action: keep
    regex: true
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
    action: replace
    regex: (https?)
    target_label: __scheme__
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
    action: replace
    target_label: __metrics_path__
    regex: (.+)
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    action: replace
    regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
    replacement: '[$2]:$1'
    target_label: __address__
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port, __meta_kubernetes_pod_ip]
    action: replace
    regex: (\d+);((([0-9]+?)(\.|$)){4})
    replacement: $2:$1
    target_label: __address__
  - action: labelmap
    regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
    replacement: __param_$1
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_pod_name]
    action: replace
    target_label: pod
  - source_labels: [__meta_kubernetes_pod_phase]
    regex: Pending|Succeeded|Failed|Completed
    action: drop
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: node
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_name]
    separator: ; 
    regex: mysql
    action: drop
{{- end -}}

{{- define "addons.mysql-metrics" -}}
honor_labels: true
kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      own_namespace: true
      names: 
      - {{ include "common.names.namespace" .context }}
params:
  collect[]:
  - informationSchema.processlist
  - performanceSchema.replication_group_members
  - performanceSchema.replication_group_member_stats
  - performanceSchema.replication_applier_status_by_worker
  - auto_increment.columns
  - binlog_size


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
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: service
  - source_labels: [__meta_kubernetes_pod_node_name]
    action: replace
    target_label: node
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_name]
    separator: ; 
    regex: mysql
    action: keep
{{- end -}}
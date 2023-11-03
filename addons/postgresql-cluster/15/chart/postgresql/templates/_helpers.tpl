{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "patroni.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "patroni.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "patroni.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "patroni.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "patroni.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create patroni envs.
*/}}
{{- define "patroni.envs" }}
{{- if .Values.kubernetes.configmaps.enable }}
- name: KUBERNETES_USE_CONFIGMAPS
  value: "true"
{{- end }}
{{- if .Values.kubernetes.endpoints.enable }}
- name: PATRONI_KUBERNETES_USE_ENDPOINTS
  value: 'true'
{{- end }}
- name: PATRONI_KUBERNETES_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: PATRONI_KUBERNETES_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: PATRONI_KUBERNETES_BYPASS_API_SERVICE
  value: 'true'
- name: PATRONI_KUBERNETES_LABELS
  value: '{app: {{ template "patroni.fullname" . }},release: {{ .Release.Name }},cluster-name: {{ template "patroni.fullname" . }}}'
- name: PATRONI_SUPERUSER_USERNAME
  value: postgres
- name: PATRONI_SUPERUSER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: password-superuser
- name: PATRONI_REPLICATION_USERNAME
  value: standby
- name: PATRONI_REPLICATION_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: password-replication
- name: PATRONI_SCOPE
  value: {{ template "patroni.fullname" . }}
- name: PATRONI_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: PATRONI_POSTGRESQL_DATA_DIR
  value: "{{ .Values.persistentVolume.mountPath }}/data"
- name: PATRONI_POSTGRESQL_PGPASS
  value: /tmp/pgpass
- name: PATRONI_POSTGRESQL_LISTEN
  value: '0.0.0.0:5432'
- name: PATRONI_RESTAPI_LISTEN
  value: '0.0.0.0:8008'
{{- end -}}

{{/*
Create wale envs.
*/}}
{{- define "wale.envs" }}
{{- if .Values.walE.enable }}
- name: USE_WALE
  value: {{ .Values.walE.enable | quote }}
{{- if .Values.walE.scheduleCronJob }}
- name: BACKUP_SCHEDULE
  value: {{ .Values.walE.scheduleCronJob | quote}}
{{- end }}
{{- if .Values.walE.retainBackups }}
- name: BACKUP_NUM_TO_RETAIN
  value: {{ .Values.walE.retainBackups | quote}}
{{- end }}
{{- if .Values.walE.s3Bucket }}
- name: WAL_S3_BUCKET
  value: {{ .Values.walE.s3Bucket | quote }}
{{else if .Values.walE.gcsBucket }}
- name: WAL_GCS_BUCKET
  value: {{ .Values.walE.gcsBucket | quote }}
{{- if .Values.walE.kubernetesSecret }}
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: "/etc/credentials/{{.Values.walE.kubernetesSecret}}.json"
{{- end }}

{{- if .Values.walE.backupThresholdMegabytes }}
- name: WALE_BACKUP_THRESHOLD_MEGABYTES
  value: {{ .Values.walE.backupThresholdMegabytes | quote }}
{{- end }}
{{- if .Values.walE.backupThresholdPercentage }}
- name: WALE_BACKUP_THRESHOLD_PERCENTAGE
  value: {{ .Values.walE.backupThresholdPercentage | quote }}
{{- end }}
{{- else }}
- name: USE_WALE
  value: ""
{{- end }}
{{- end }}
{{- end -}}
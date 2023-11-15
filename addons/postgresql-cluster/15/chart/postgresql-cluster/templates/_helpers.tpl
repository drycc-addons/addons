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
Return true if a cronjob object should be created for Postgresql HA patroni
*/}}
{{- define "patroni.createCronJob" -}}
{{- if and .Values.walG.enable }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for Postgresql HA patroni
*/}}
{{- define "patroni.createConfigmap" -}}
{{- if and .Values.preInitScript }}
    {{- true -}}
{{- else -}}
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
  value: '{application: {{ template "patroni.fullname" . }},release: {{ .Release.Name }},cluster-name: {{ template "patroni.fullname" . }}}'
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
- name: PATRONI_REWIND_USERNAME
  value: rewinder
- name: PATRONI_REWIND_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: password-rewind
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

- name: DATABASE_NAME
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: data-name
- name: DATABASE_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: data-user
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: data-password

{{- end -}}

{{/*
Create walg envs.
*/}}
{{- define "walg.envs" }}
{{- if .Values.walG.enable }}
- name: USE_WALG
  value: {{ .Values.walG.enable | quote }}
{{- if .Values.walG.scheduleCronJob }}
- name: BACKUP_SCHEDULE
  value: {{ .Values.walG.scheduleCronJob | quote}}
{{- end }}
{{- if .Values.walG.retainBackups }}
- name: BACKUP_NUM_TO_RETAIN
  value: {{ .Values.walG.retainBackups | quote}}
{{- end }}
{{- if .Values.walG.backupThresholdMegabytes }}
- name: WALG_BACKUP_THRESHOLD_MEGABYTES
  value: {{ .Values.walG.backupThresholdMegabytes | quote }}
{{- end }}
{{- if .Values.walG.backupThresholdPercentage }}
- name: WALE_BACKUP_THRESHOLD_PERCENTAGE
  value: {{ .Values.walG.backupThresholdPercentage | quote }}
{{- end }}
{{- if .Values.walG.s3.used }}
- name: AWS_ACCESS_KEY_ID
  value: {{ .Values.walG.s3.awsAccessKeyId | quote }}
- name: AWS_SECRET_ACCESS_KEY
  value: {{ .Values.walG.s3.awsSecretAccessKey | quote }}
- name: WALG_S3_PREFIX
  value: {{ .Values.walG.s3.walGS3Prefix | quote }}
- name: AWS_ENDPOINT
  value: {{ .Values.walG.s3.awsEndpoint | quote }}
- name: AWS_S3_FORCE_PATH_STYLE
  value: {{ .Values.walG.s3.awsS3ForcePathStyle | quote }}
- name: AWS_REGION
  value: {{ .Values.walG.s3.awsRegion | quote }}
{{- end }}
{{- else }}
- name: USE_WALG
  value: ""
{{- end }}
{{- end }}

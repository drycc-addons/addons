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
Return true if a cronjob object should be created for Postgresql HA patroni ## TODO feature
*/}}
{{- define "patroni.createCronJob" -}}
{{- if and .Values.backup.enabled }}
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
- name: ADMIN_USER
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: admin-user
- name: ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "patroni.fullname" . }}
      key: admin-password
- name: PATRONI_SCOPE
  value: {{ template "patroni.fullname" . }}
- name: PATRONI_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: PATRONI_POSTGRESQL_DATA_DIR
  value: "{{ .Values.persistentVolume.mountPath }}/data"
- name: PGDATA
  value: "{{ .Values.persistentVolume.mountPath }}/data"
- name: PATRONI_POSTGRESQL_PGPASS
  value: /tmp/pgpass
- name: PATRONI_POSTGRESQL_LISTEN
  value: '0.0.0.0:5432'
- name: PATRONI_RESTAPI_LISTEN
  value: '0.0.0.0:8008'
{{- end -}}

{{/*
Create walg envs.
*/}}
{{- define "backup.envs" }}
{{- if .Values.backup.enabled }}
- name: USE_WALG
  value: {{ .Values.backup.enabled | quote }}
{{- if .Values.backup.retainBackups }}
- name: BACKUP_NUM_TO_RETAIN
  value: {{ .Values.backup.retainBackups | quote}}
{{- end }}
{{- if .Values.backup.backupThresholdMegabytes }}
- name: WALG_BACKUP_THRESHOLD_MEGABYTES
  value: {{ .Values.backup.backupThresholdMegabytes | quote }}
{{- end }}
{{- if .Values.backup.backupThresholdPercentage }}
- name: WALE_BACKUP_THRESHOLD_PERCENTAGE
  value: {{ .Values.backup.backupThresholdPercentage | quote }}
{{- end }}
{{- if .Values.backup.s3.used }}
- name: AWS_ACCESS_KEY_ID
  value: {{ .Values.backup.s3.awsAccessKeyID | quote }}
- name: AWS_SECRET_ACCESS_KEY
  value: {{ .Values.backup.s3.awsSecretAccessKey | quote }}
- name: WALG_S3_PREFIX
  value: {{ .Values.backup.s3.walGS3Prefix | quote }}
- name: AWS_ENDPOINT
  value: {{ .Values.backup.s3.awsEndpoint | quote }}
- name: AWS_S3_FORCE_PATH_STYLE
  value: {{ .Values.backup.s3.awsS3ForcePathStyle | quote }}
- name: AWS_REGION
  value: {{ .Values.backup.s3.awsRegion | quote }}
{{- end }}
{{- else }}
- name: USE_WALG
  value: ""
{{- end }}
{{- end }}

{{/*
Generate random password 
*/}}

{{/*
Get the super user  password ;
*/}}
{{- define "credentials.superuserValue" }}
{{- if .Values.credentials.superuser }}                                         
    {{- .Values.credentials.superuser -}}
{{- else -}}
  {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "password-superuser")  -}}
{{- end -}}
{{- end }}

{{/*
Get the rewind password ;
*/}}
{{- define "credentials.rewindValue" }}
{{- if .Values.credentials.rewind }}                                         
    {{- .Values.credentials.rewind -}}
{{- else -}}
  {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "password-rewind")  -}}
{{- end -}}
{{- end }}

{{/*
Get the replication password ;
*/}}
{{- define "credentials.replicationValue" }}
{{- if .Values.credentials.replication }}                                         
    {{- .Values.credentials.replication -}}
{{- else -}}
  {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "password-replication")  -}}
{{- end -}}
{{- end }}

{{/*
Get the administrator password ;
*/}}
{{- define "adminRole.passwordValue" }}
{{- if .Values.adminRole.password }}
    {{- .Values.adminRole.password -}}
{{- else -}}
  {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "password-replication")  -}}
{{- end -}}
{{- end }}

{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "getValueFromSecret" }}
{{- $len := (default 16 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $obj }}
{{- index $obj .Key | b64dec -}}
{{- else -}}
{{- randAlphaNum $len -}}
{{- end -}}
{{- end }}


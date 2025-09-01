{{/* vim: set filetype=mustache: */}}


{{/*
Full name for portal service
*/}}
{{- define "apollo.portal.fullName" -}}
{{- if .Values.portal.fullNameOverride -}}
{{- .Values.portal.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if contains .Values.portal.name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.portal.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "apollo.labels" -}}
{{- if .Chart.AppVersion -}}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Service name for portal
*/}}
{{- define "apollo.portal.serviceName" -}}
{{- if .Values.portal.service.fullNameOverride -}}
{{- .Values.portal.service.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "apollo.portal.fullName" .}}
{{- end -}}
{{- end -}}


{{/* vim: set filetype=mustache: */}}

{{/*
Service name for configdb
*/}}
{{- define "apollo.configdb.serviceName" -}}
{{- .Values.apolloService.configdb.host -}}
{{- end -}}

{{/*
Service port for configdb
*/}}
{{- define "apollo.configdb.servicePort" -}}
{{- if .Values.apolloService.configdb.service.enabled -}}
{{- .Values.apolloService.configdb.service.port -}}
{{- else -}}
{{- .Values.apolloService.configdb.port -}}
{{- end -}}
{{- end -}}

{{/*
Full name for config service
*/}}
{{- define "apollo.configService.fullName" -}}
{{- if .Values.apolloService.configService.fullNameOverride -}}
{{- .Values.apolloService.configService.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if contains .Values.apolloService.configService.name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.apolloService.configService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service name for config service
*/}}
{{- define "apollo.configService.serviceName" -}}
{{- if .Values.apolloService.configService.service.fullNameOverride -}}
{{- .Values.apolloService.configService.service.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "apollo.configService.fullName" .}}
{{- end -}}
{{- end -}}

{{/*
Config service url to be accessed by apollo-client
*/}}
{{- define "apollo.configService.serviceUrl" -}}
{{- if .Values.apolloService.configService.config.configServiceUrlOverride -}}
{{ .Values.apolloService.configService.config.configServiceUrlOverride }}
{{- else -}}
http://{{ include "apollo.configService.serviceName" .}}.{{ .Release.Namespace }}:{{ .Values.apolloService.configService.service.port }}{{ .Values.apolloService.configService.config.contextPath }}
{{- end -}}
{{- end -}}

{{/*
Full name for admin service
*/}}
{{- define "apollo.adminService.fullName" -}}
{{- if .Values.apolloService.adminService.fullNameOverride -}}
{{- .Values.apolloService.adminService.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if contains .Values.apolloService.adminService.name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.apolloService.adminService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service name for admin service
*/}}
{{- define "apollo.adminService.serviceName" -}}
{{- if .Values.apolloService.adminService.service.fullNameOverride -}}
{{- .Values.apolloService.adminService.service.fullNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "apollo.adminService.fullName" .}}
{{- end -}}
{{- end -}}

{{/*
Admin service url to be accessed by apollo-portal
*/}}
{{- define "apollo.adminService.serviceUrl" -}}
{{- if .Values.apolloService.configService.config.adminServiceUrlOverride -}}
{{ .Values.apolloService.configService.config.adminServiceUrlOverride -}}
{{- else -}}
http://{{ include "apollo.adminService.serviceName" .}}.{{ .Release.Namespace }}:{{ .Values.apolloService.adminService.service.port }}{{ .Values.apolloService.adminService.config.contextPath }}
{{- end -}}
{{- end -}}

{{/*
Copyright VMware, Inc.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}


{{/*
Return the proper seaweedfs image name
*/}}
{{- define "seaweedfs.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the deployment
*/}}
{{- define "seaweedfs.fullname" -}}
    {{ printf "%s" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "seaweedfs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "seaweedfs.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "seaweedfs.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Name the configuration configmap
*/}}
{{- define "seaweedfs.configuration.configMap" -}}
{{- printf "%s-config" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Name the filer full name
*/}}
{{- define "seaweedfs.filer.fullname" -}}
{{- printf "%s-filer" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name the master full name
*/}}
{{- define "seaweedfs.master.fullname" -}}
{{- printf "%s-master" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Name the volume full name
*/}}
{{- define "seaweedfs.volume.fullname" -}}
{{- printf "%s-volume" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name the cronjob full name
*/}}
{{- define "seaweedfs.cronjob.fullname" -}}
{{- printf "%s-cronjob" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Master peers url
*/}}
{{- define "seaweedfs.master.peers" -}}
{{- $replicaCount := int .Values.master.replicas }}
{{- $clusterDomain := .Values.global.clusterDomain }}
{{- $messages := list -}}
{{ range $i := until $replicaCount }}
  {{- $messages = printf "%s-%d.%s.%s.svc.%s:%v" (include "seaweedfs.master.fullname" $) $i (include "seaweedfs.master.fullname" $) $.Release.Namespace $clusterDomain $.Values.master.ports.http | append $messages -}}
{{ end }}
{{- $message := join "," $messages -}}
{{- printf "%s" $message }}
{{- end -}}

{{/*
Master filer url
*/}}
{{- define "seaweedfs.filer.url" -}}
{{- printf "%s.%s.svc.%s:%v" (include "seaweedfs.filer.fullname" .) .Release.Namespace .Values.global.clusterDomain .Values.filer.ports.http }}
{{- end -}}
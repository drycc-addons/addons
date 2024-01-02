{{/*
Copyright Drycc Community.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper Fluentbit image name
*/}}
{{- define "fluentbit.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "fluentbit.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) -}}
{{- end -}}

{{/*
Name the fluentbit configmap
*/}}
{{- define "fluentbit.configMap" -}}
{{- printf "%s-config" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fluentbit.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Name the daemonset fullname
*/}}
{{- define "fluentbit.daemonset.fullname" -}}
{{- printf "%s-agent" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name the deployment fullname
*/}}
{{- define "fluentbit.deployment.fullname" -}}
{{- printf "%s-controller" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Fluentbit Reloader image name
*/}}
{{- define "fluentbit.reloader.image" -}}
{{- if and .Values.reloader.image.repository .Values.reloader.image.tag -}}
{{- include "common.images.image" (dict "imageRoot" .Values.reloader.image "global" .Values.global) -}}
{{- else -}}
{{- include "fluentbit.image" . -}}
{{- end -}}
{{- end -}}

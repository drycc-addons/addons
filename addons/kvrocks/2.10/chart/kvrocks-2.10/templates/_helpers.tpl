{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper kvrocks image name
*/}}
{{- define "kvrocks.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper kvrocks Sentinel image name
*/}}
{{- define "kvrocks.sentinel.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sentinel.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper kvrocks Proxy image name
*/}}
{{- define "kvrocks.proxy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.proxy.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "kvrocks.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "kvrocks.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return sysctl image
*/}}
{{- define "kvrocks.sysctl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sysctl.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "kvrocks.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.sentinel.image .Values.metrics.image .Values.volumePermissions.image .Values.sysctl.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiGroup for PodSecurityPolicy.
*/}}
{{- define "podSecurityPolicy.apiGroup" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy" -}}
{{- else -}}
{{- print "extensions" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "kvrocks.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the configuration configmap name
*/}}
{{- define "kvrocks.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-configuration" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "kvrocks.createConfigmap" -}}
{{- if empty .Values.existingConfigmap }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "kvrocks.secretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- printf "%s" .Values.auth.existingSecret -}}
{{- else -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from kvrocks&trade; secret.
*/}}
{{- define "kvrocks.secretPasswordKey" -}}
{{- if and .Values.auth.existingSecret .Values.auth.existingSecretPasswordKey -}}
{{- printf "%s" .Values.auth.existingSecretPasswordKey -}}
{{- else -}}
{{- printf "kvrocks-password" -}}
{{- end -}}
{{- end -}}


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

{{/*
Return kvrocks&trade; password
*/}}
{{- define "kvrocks.password" -}}
{{- if not (empty .Values.global.kvrocks.password) }}
    {{- .Values.global.kvrocks.password -}}
{{- else if not (empty .Values.auth.password) -}}
    {{- .Values.auth.password -}}
{{- else -}}
    {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" (include "common.names.fullname" .) "Length" 10 "Key" "kvrocks-password")  -}}
{{- end -}}
{{- end -}}

{{/* Check if there are rolling tags in the images */}}
{{- define "kvrocks.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.sentinel.image }}
{{- include "common.warnings.rollingTag" .Values.metrics.image }}
{{- end -}}

{{/* Validate values of kvrocks&trade; - spreadConstrainsts K8s version */}}
{{- define "kvrocks.validateValues.topologySpreadConstraints" -}}
{{- if and (semverCompare "<1.16-0" .Capabilities.KubeVersion.GitVersion) .Values.replica.topologySpreadConstraints -}}
kvrocks: topologySpreadConstraints
    Pod Topology Spread Constraints are only available on K8s  >= 1.16
    Find more information at https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
{{- end -}}
{{- end -}}

{{/* Validate values of kvrocks&trade; - must provide a valid architecture */}}
{{- define "kvrocks.validateValues.architecture" -}}
{{- if and (ne .Values.architecture "standalone") (ne .Values.architecture "replication") -}}
kvrocks: architecture
    Invalid architecture selected. Valid values are "standalone" and
    "replication". Please set a valid architecture (--set architecture="xxxx")
{{- end -}}
{{- if and .Values.sentinel.enabled (not (eq .Values.architecture "replication")) }}
kvrocks: architecture
    Using kvrocks sentinel on standalone mode is not supported.
    To deploy kvrocks sentinel, please select the "replication" mode
    (--set "architecture=replication,sentinel.enabled=true")
{{- end -}}
{{- end -}}

{{/* Validate values of kvrocks&trade; - PodSecurityPolicy create */}}
{{- define "kvrocks.validateValues.podSecurityPolicy.create" -}}
{{- if and .Values.podSecurityPolicy.create (not .Values.podSecurityPolicy.enabled) }}
kvrocks: podSecurityPolicy.create
    In order to create PodSecurityPolicy, you also need to enable
    podSecurityPolicy.enabled field
{{- end -}}
{{- end -}}

{{/* Define the suffix utilized for external-dns */}}
{{- define "kvrocks.externalDNS.suffix" -}}
{{ printf "%s.%s" (include "common.names.fullname" .) .Values.useExternalDNS.suffix }}
{{- end -}}

{{/* Compile all annotations utilized for external-dns */}}
{{- define "kvrocks.externalDNS.annotations" -}}
{{- if .Values.useExternalDNS.enabled }}
{{ .Values.useExternalDNS.annotationKey }}hostname: {{ include "kvrocks.externalDNS.suffix" . }}
{{- range $key, $val := .Values.useExternalDNS.additionalAnnotations }}
{{ $.Values.useExternalDNS.annotationKey }}{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

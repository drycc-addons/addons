{{/*
Copyright Drycc Community.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Returns the container that will statsd metrics
Usage:
{{ include "airflow.statsd.container" ( dict "securityContext" .Values.path.to.the.component.securityContext "context" $ ) }}
*/}}
{{- define "airflow.statsd.container" -}}
- name: statsd
  image: {{ include "airflow.statsdImage" .context | quote }}
  imagePullPolicy: {{ .context.Values.statsd.image.pullPolicy | quote }}
  {{- if .securityContext.enabled }}
  securityContext: {{- omit .securityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .context.Values.statsd.lifecycleHooks }}
  lifecycle: {{- include "common.tplvalues.render" (dict "value" .context.Values.statsd.lifecycleHooks "context" $) | nindent 4 }}
  {{- end }}
  {{- if .context.Values.statsd.resources }}
  resources: {{- toYaml .context.Values.statsd.resources | nindent 4 }}
  {{- end }}
  {{- with .context.Values.statsd.env }}
  env: {{- toYaml . | nindent 4 }}
  {{- end }}
  ports:
    - name: statsd-scrape
      containerPort: {{ .context.Values.statsd.ports.scrape }}
  livenessProbe:
    httpGet:
      path: /metrics
      port: {{ .context.Values.statsd.ports.scrape }}
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
  readinessProbe:
    httpGet:
      path: /metrics
      port: {{ .context.Values.statsd.ports.scrape }}
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
{{- end -}}

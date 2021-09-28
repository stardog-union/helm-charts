{{- define "stardog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stardog.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "stardog" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zkservers" -}}
{{- $zk := dict "servers" (list) -}}
{{- $namespace := include "stardog.namespace" . -}}
{{- $name := .Release.Name -}}
{{- range int .Values.zookeeper.replicaCount | until -}}
{{- $noop := printf "%s-zookeeper-%d.%s-zookeeper-headless.%s:2181" $name . $name $namespace | append $zk.servers | set $zk "servers" -}}
{{- end -}}
{{- join "," $zk.servers -}}
{{- end -}}

{{- define "imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.image.registry (printf "%s:%s" .Values.image.username .Values.image.password | b64enc) | b64enc }}
{{- end -}}

{{- define "imagePullSecretBusybox" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.busybox.image.registry (printf "%s:%s" .Values.busybox.image.username .Values.busybox.image.password | b64enc) | b64enc }}
{{- end -}}

{{/*
Return Stardog namespace to use
*/}}
{{- define "stardog.namespace" -}}
{{- if .Values.namespaceOverride -}}
{{- .Values.namespaceOverride -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

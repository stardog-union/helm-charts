{{- define "stardog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "zkservers" -}}
{{- $zk := dict "servers" (list) -}}
{{- $namespace := .Release.Namespace -}}
{{- $name := .Release.Name -}}
{{- range int .Values.zookeeper.replicaCount | until -}}
{{- $noop := printf "%s-zookeeper-%d.%s-zookeeper-headless.%s:2181" $name . $name $namespace | append $zk.servers | set $zk "servers" -}}
{{- end -}}
{{- join "," $zk.servers -}}
{{- end -}}

{{- define "imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.image.registry (printf "%s:%s" .Values.image.username .Values.image.password | b64enc) | b64enc }}
{{- end -}}
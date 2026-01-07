{{/*
Expand the name of the chart.
*/}}
{{- define "trellis2.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trellis2.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trellis2.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trellis2.labels" -}}
helm.sh/chart: {{ include "trellis2.chart" . }}
{{ include "trellis2.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trellis2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trellis2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trellis2.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trellis2.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "trellis2.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end }}

{{/*
Return the HuggingFace secret name
*/}}
{{- define "trellis2.huggingfaceSecretName" -}}
{{- if .Values.huggingface.existingSecret }}
{{- .Values.huggingface.existingSecret }}
{{- else }}
{{- printf "%s-huggingface" (include "trellis2.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the model cache PVC name
*/}}
{{- define "trellis2.modelCachePvcName" -}}
{{- if .Values.persistence.modelCache.existingClaim }}
{{- .Values.persistence.modelCache.existingClaim }}
{{- else }}
{{- printf "%s-model-cache" (include "trellis2.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the output PVC name
*/}}
{{- define "trellis2.outputPvcName" -}}
{{- if .Values.persistence.output.existingClaim }}
{{- .Values.persistence.output.existingClaim }}
{{- else }}
{{- printf "%s-output" (include "trellis2.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the ConfigMap name
*/}}
{{- define "trellis2.configMapName" -}}
{{- printf "%s-config" (include "trellis2.fullname" .) }}
{{- end }}

{{/*
Return the Secret name
*/}}
{{- define "trellis2.secretName" -}}
{{- printf "%s-secret" (include "trellis2.fullname" .) }}
{{- end }}

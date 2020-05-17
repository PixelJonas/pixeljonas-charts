{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "contao-cms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "contao-cms.fullname" -}}
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
Create the database-url to be used
*/}}
{{- define "database.secretName" -}}
{{- template "contao-cms.fullname" . }}-secret
{{- end -}}

{{- define "database.password" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "database.secretName" .) ) -}}
{{- if $secret -}}
{{/* 
   Reusing current password since secret exists
*/}}
{{-  $secret.data.DATABASE_PASSWORD -}}
{{- else if .Values.database.password -}}
{{- .Values.database.password -}}
{{- else -}}
{{/* 
    Generate new password
*/}}
{{- randAlpha 14 -}}
{{- end -}}
{{- end -}}

{{- define "database.rootpassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "database.secretName" .) ) -}}
{{- if $secret -}}
{{/* 
   Reusing current password since secret exists
*/}}
{{-  $secret.data.DATABASE_ROOT_PASSWORD -}}
{{- else if .Values.database.rootpassword -}}
{{- .Values.database.rootpassword -}}
{{- else -}}
{{/* 
    Generate new password
*/}}
{{- randAlpha 14 -}}
{{- end -}}
{{- end -}}

{{- define "database.url" -}}
{{- printf "mysql://%s:%s@localhost:3306/%s" .Values.database.user (include "database.password" .) .Values.database.name | b64enc | quote -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "contao-cms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "contao-cms.labels" -}}
helm.sh/chart: {{ include "contao-cms.chart" . }}
{{ include "contao-cms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "contao-cms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "contao-cms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "contao-cms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "contao-cms.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

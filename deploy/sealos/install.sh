#!/bin/bash

set -euo pipefail

NAMESPACE=${NAMESPACE:-"jotlin"}
RELEASE_NAME=${RELEASE_NAME:-"jotlin"}
SECRET_NAME=${SECRET_NAME:-"jotlin-secret"}
CHART_DIR=${CHART_DIR:-"./charts/jotlin"}
VALUES_FILE=${VALUES_FILE:-"./charts/jotlin.values.yaml"}
HELM_OPTS=${HELM_OPTS:-""}

get_configmap_value() {
  local namespace="$1"
  local name="$2"
  local jsonpath="$3"
  kubectl get configmap "${name}" -n "${namespace}" -o "jsonpath=${jsonpath}" 2>/dev/null || true
}

require_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

CLOUD_DOMAIN=${CLOUD_DOMAIN:-$(get_configmap_value "sealos-system" "sealos-config" '{.data.cloudDomain}')}
CLOUD_PORT=${CLOUD_PORT:-$(get_configmap_value "sealos-system" "sealos-config" '{.data.cloudPort}')}
SEALOS_JWT_SECRET=${SEALOS_JWT_SECRET:-$(get_configmap_value "sealos-system" "sealos-config" '{.data.jwtInternal}')}

if [[ -z "${SEALOS_JWT_SECRET}" ]]; then
  SEALOS_JWT_SECRET=$(get_configmap_value "sealos" "desktop-frontend-config" '{.data.jwt}')
fi

CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.1.0")
VERSION=${VERSION:-${CURRENT_TAG#v}}

if [[ -n "${NEXT_PUBLIC_BASE_URL:-}" ]]; then
  APP_HOST=$(printf '%s' "${NEXT_PUBLIC_BASE_URL}" | sed -E 's#https?://([^/]+).*#\1#')
else
  if [[ -z "${CLOUD_DOMAIN}" ]]; then
    echo "Missing CLOUD_DOMAIN and NEXT_PUBLIC_BASE_URL; cannot determine public host." >&2
    exit 1
  fi
  APP_HOST=${APP_HOST:-"jotlin.${CLOUD_DOMAIN}"}
  NEXT_PUBLIC_BASE_URL="https://${APP_HOST}"
fi

OPENAI_API_BASE_URL=${OPENAI_API_BASE_URL:-"https://api.openai.com/v1"}
S3_ENDPOINT=${S3_ENDPOINT:-"http://minio.minio.svc.cluster.local:9000"}
S3_BUCKET_NAME=${S3_BUCKET_NAME:-"jotlin"}
S3_PUBLIC_URL=${S3_PUBLIC_URL:-}
if [[ -z "${S3_PUBLIC_URL}" && -n "${CLOUD_DOMAIN}" ]]; then
  S3_PUBLIC_URL="https://s3.${CLOUD_DOMAIN}"
fi

TLS_SECRET_NAME=${TLS_SECRET_NAME:-"${RELEASE_NAME}-tls"}

require_var "DATABASE_URL"
require_var "OPENAI_API_KEY"
require_var "JWT_SECRET"
require_var "S3_ACCESS_KEY"
require_var "S3_SECRET_KEY"

TAVILY_API_KEY=${TAVILY_API_KEY:-""}
GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID:-""}
GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET:-""}
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-""}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-""}

echo "Installing ${RELEASE_NAME} into namespace ${NAMESPACE}"
echo "Version: ${VERSION}"
echo "Public URL: ${NEXT_PUBLIC_BASE_URL}"
echo "Cloud domain: ${CLOUD_DOMAIN:-<unset>}"
echo "Cloud port: ${CLOUD_PORT:-<unset>}"
echo "Secret name: ${SECRET_NAME}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal=DATABASE_URL="${DATABASE_URL}" \
  --from-literal=NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL}" \
  --from-literal=OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --from-literal=OPENAI_API_BASE_URL="${OPENAI_API_BASE_URL}" \
  --from-literal=TAVILY_API_KEY="${TAVILY_API_KEY}" \
  --from-literal=GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID}" \
  --from-literal=GITHUB_CLIENT_SECRET="${GITHUB_CLIENT_SECRET}" \
  --from-literal=GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID}" \
  --from-literal=GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET}" \
  --from-literal=JWT_SECRET="${JWT_SECRET}" \
  --from-literal=SEALOS_JWT_SECRET="${SEALOS_JWT_SECRET}" \
  --from-literal=S3_ENDPOINT="${S3_ENDPOINT}" \
  --from-literal=S3_ACCESS_KEY="${S3_ACCESS_KEY}" \
  --from-literal=S3_SECRET_KEY="${S3_SECRET_KEY}" \
  --from-literal=S3_BUCKET_NAME="${S3_BUCKET_NAME}" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

# shellcheck disable=SC2086
helm upgrade -i "${RELEASE_NAME}" "${CHART_DIR}" -n "${NAMESPACE}" --create-namespace \
  -f "${VALUES_FILE}" \
  --set-string secret.create=false \
  --set-string secret.existingSecret="${SECRET_NAME}" \
  --set-string image.tag="${VERSION}" \
  --set-string migrationJob.image.tag="${VERSION}" \
  --set-string env.NEXT_PUBLIC_BASE_URL="${NEXT_PUBLIC_BASE_URL}" \
  --set-string env.OPENAI_API_BASE_URL="${OPENAI_API_BASE_URL}" \
  --set-string env.S3_ENDPOINT="${S3_ENDPOINT}" \
  --set-string env.S3_PUBLIC_URL="${S3_PUBLIC_URL}" \
  --set-string env.S3_BUCKET_NAME="${S3_BUCKET_NAME}" \
  --set-string ingress.hosts[0].host="${APP_HOST}" \
  --set-string ingress.tls[0].hosts[0]="${APP_HOST}" \
  --set-string ingress.tls[0].secretName="${TLS_SECRET_NAME}" \
  ${HELM_OPTS}

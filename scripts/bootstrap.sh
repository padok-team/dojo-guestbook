#! /usr/bin/env bash

set -e

# Helpers for readability.
bold=$(tput bold)
normal=$(tput sgr0)
function _info() {
    echo "${bold}${1}${normal}"
}

CLUSTER_NAME=theodo-training

# Run script from directory where the script is stored.
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Create a local Kubernetes cluster if necessary.
if kind get clusters | grep "$CLUSTER_NAME"; then
    _info "🚀 $CLUSTER_NAME already exists!"
    exit 0
else
    _info "🔧 Creating a local Kubernetes cluster..."
    kind create cluster --name=$CLUSTER_NAME --config=../kind-cluster.yaml
fi

# Install Traefik and Gateway API CRDs
_info "📥 Installing an ingress controller..."
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.0/standard-install.yaml
helm repo add traefik https://traefik.github.io/charts --force-update
helm upgrade --install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --set service.spec.type=NodePort \
  --set ports.web.nodePort=30080 \
  --set ports.websecure.nodePort=30443 \
  --set providers.kubernetesGateway.enabled=true \
  --set gateway.listeners.web.namespacePolicy.from=All \
  --set image.registry=mirror.gcr.io \
  --wait

# Install metrics server
_info "📥 Installing metric server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

_info "🚀 You are ready to go!"

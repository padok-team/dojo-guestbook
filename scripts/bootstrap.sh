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

# Install the NGINX ingress controller.
_info "📥 Installing an ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl rollout status deployment --namespace=ingress-nginx ingress-nginx-controller

# Install metrics server
_info "📥 Installing metric server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.8.0/components.yaml
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

_info "🚀 You are ready to go!"

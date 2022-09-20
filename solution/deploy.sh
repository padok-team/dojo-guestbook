#! /usr/bin/env bash

set -e

# Helpers for readability.
bold=$(tput bold)
normal=$(tput sgr0)
function _info() {
    echo "${bold}${1}${normal}"
}

CLUSTER_NAME=padok-training

# Run script from directory where the script is stored.
cd "$( dirname "${BASH_SOURCE[0]}" )"

_info "🔧 Building guestbook dokcer image..."
docker build -t guestbook:v0.1.0 -f Dockerfile ../

_info "📥 Loading guestbook image to kind cluster..."
kind load docker-image --name=$CLUSTER_NAME guestbook:v0.1.0

_info "📥 Deploying redis..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade redis bitnami/redis \
            --wait \
            --install \
            --values=helm/values/redis.yaml

_info "📥 Deploying guestbook..."
kubectl apply -f manifests/

_info "🚀 You are ready to go!"

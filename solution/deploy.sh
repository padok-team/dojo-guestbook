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

_info "🔧 Building guestbook docker image..."
docker build -t guestbook:v0.1.0 -f Dockerfile ../

_info "📥 Loading guestbook image to kind cluster..."
kind load docker-image --name=$CLUSTER_NAME guestbook:v0.1.0

_info "📥 Deploying redis..."
helm upgrade redis oci://registry-1.docker.io/cloudpirates/redis --version 0.4.6 \
            --wait \
            --install \
            --values=helm/values/redis.yaml

_info "📥 Deploying guestbook..."
kubectl apply -f manifests/

_info "🚀 You are ready to go!"

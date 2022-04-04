#! /usr/bin/env bash

set -e

# Helpers for readability.
bold=$(tput bold)
normal=$(tput sgr0)
function _info() {
    echo "${bold}${1}${normal}"
}

# Run script from directory where the script is stored.
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Delete the Kubernetes cluster.
_info "💥 Destroying the local Kubernetes cluster..."
kind delete cluster --name=padok-training

_info "👋 See you again soon!"

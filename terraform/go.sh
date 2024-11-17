#!/usr/bin/env bash
set -e

pushd k8s-setup
./go.sh
popd

pushd k8s
./go.sh
popd
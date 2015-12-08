#!/bin/bash
set -e # exit if any command fails

readonly OUT_IMG=${DOCKER_IMG:-"docker.kivra.net/buildkite-agent:${BUILDKITE_BRANCH}"}

function build_image() {
    echo "--- Building Docker image"
    docker build --no-cache -t "${OUT_IMG}" .
}

function docker_push() {
    echo "--- Pushing to Docker registry"
    docker push "${OUT_IMG}"
}

build_image
docker_push

#!/bin/bash
set -euo pipefail

TAG="mt3593/grafana-backup:$1"
 
docker build -t "$TAG" .

docker push "$TAG"

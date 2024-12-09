#!/bin/bash

echo "Checking if docker compose is installed.."

docker compose &>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ installed"
else
    echo "❌ docker compose is not installed"
fi

echo "Checking is docker containers are running.."

if [ $(docker container inspect --format '{{.State.Status}}' ugain-control-plane) == "running" ]; then
  echo "✅ kind control plane is running"
else
  echo "❌ kind control plane is not running"
  exit 1
fi

if [ $(docker container inspect --format '{{.State.Status}}' ugain-worker) == "running" ]; then
  echo "✅ kind worker is running"
else
  echo "❌ kind worker is not running"
  exit 1
fi

if [ $(docker container inspect --format '{{.State.Status}}' kind-registry) == "running" ]; then
  echo "✅ kind registry is running"
else
  echo "❌ kind registry is not running"
  exit 1
fi

echo "Downloading docker images.. this can take few minutes"

docker pull anibali/pytorch:cuda-10.0

if [ $? -eq 0 ]; then
    echo "✅ image pulled"
else
    echo "❌ could not pull docker image"
    exit 1
fi

echo "Checking is k8s cluster is running.." 

kubectl get nodes

if [ $? -eq 0 ]; then
    echo "✅ K8S api server is reachable"
else
    echo "❌ K8S api server is not reachable"
    exit 1
fi

echo "Everything looks good, cleaning up running containers.."

kind delete cluster --name ugain

if [ $? -eq 0 ]; then
    echo "✅ Kubernetes cluster is deleted"
else
    echo "❌ Could not delete Kubernetes cluster"
    exit 1
fi

docker stop kind-registry && docker rm kind-registry

if [ $? -eq 0 ]; then
    echo "✅ Container registry is deleted"
else
    echo "❌ Could not delete container registry"
    exit 1
fi

echo "Smoke test is done!"

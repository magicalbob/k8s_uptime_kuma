#!/usr/bin/env bash

if [ -z "$UPTIME_IP" ]
then
  echo "Environment variable UPTIME_IP has to be provided"
  exit 1
fi

if [ -z "$UPTIME_USERNAME" ]
then
  echo "Environment variable UPTIME_USERNAME has to be provided"
  exit 2
fi

if [ -z "$UPTIME_PASSWORD" ]
then
  echo "Environment variable UPTIME_PASSWORD has to be provided"
  exit 3
fi

unset USE_KIND
# Check if kubectl is available in the system
if kubectl 2>/dev/null >/dev/null; then
  # Check if kubectl can communicate with a Kubernetes cluster
  if kubectl get nodes 2>/dev/null >/dev/null; then
    echo "Kubernetes cluster is available. Using existing cluster."
    export USE_KIND=0
  else
    echo "Kubernetes cluster is not available. Creating a Kind cluster..."
    export USE_KIND=X
  fi
else
  echo "kubectl is not installed. Please install kubectl to interact with Kubernetes."
  export USE_KIND=X
fi

if [ "X${USE_KIND}" == "XX" ]; then
    # Make sure cluster exists if Mac
    if ! kind get clusters 2>&1 | grep -q "kind-uptime-kuma"
    then
      envsubst < kind-config.yaml.template > kind-config.yaml
      kind create cluster --config kind-config.yaml --name kind-uptime-kuma
    fi

    # Make sure create cluster succeeded
    if ! kind get clusters 2>&1 | grep -q "kind-uptime-kuma"
    then
        echo "Creation of cluster failed. Aborting."
        exit 666
    fi
fi

# add metrics
kubectl apply -f https://dev.ellisbs.co.uk/files/components.yaml

# install local storage
kubectl apply -f  local-storage-class.yml

export UPTIME_KUMA_NAMESPACE=uptime-kuma

# create uptime-kuma namespace, if it doesn't exist
kubectl get ns ${UPTIME_KUMA_NAMESPACE} 2> /dev/null
if [ $? -eq 1 ]
then
    kubectl create namespace ${UPTIME_KUMA_NAMESPACE}
fi

# create deployment
kubectl apply -f uptime-kuma-deployment.yml

# sort out persistent volume
if [ "X${USE_KIND}" == "XX" ];then
  export NODE_NAME=$(kubectl get nodes |grep control-plane|cut -d\  -f1|head -1)
  envsubst < uptime-kuma.pv.kind.template > uptime-kuma.pv.yml
else
  export NODE_NAME=$(kubectl get nodes | grep -v ^NAME|grep -v control-plane|cut -d\  -f1|head -1)
  envsubst < uptime-kuma.pv.linux.template > uptime-kuma.pv.yml
  echo mkdir -p ${PWD}/uptime-kuma-data|ssh -o StrictHostKeyChecking=no ${NODE_NAME}
fi
kubectl apply -f uptime-kuma.pv.yml

# Wait for pod to be running
until kubectl get pod -n ${UPTIME_KUMA_NAMESPACE} | grep 1/1; do
  sleep 5
done

# Set up port-forward
kubectl port-forward service/uptime-kuma-service -n uptime-kuma --address ${UPTIME_IP} 3001:3001 &

# Create user from UPTIME_IP/UPTIME_USERNAME/UPTIME_PASSWORD variables (will fail if already present in PV)
python/create_user.py

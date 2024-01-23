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
        exit 255
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
  NODE_NAME=$(kubectl get nodes |grep control-plane|cut -d\  -f1|head -1)
  export NODE_NAME
  envsubst < uptime-kuma.pv.kind.template > uptime-kuma.pv.yml
else
  NODE_NAME=$(kubectl get nodes | grep -v ^NAME|grep -v control-plane|cut -d\  -f1|head -1)
  export NODE_NAME
  envsubst < uptime-kuma.pv.linux.template > uptime-kuma.pv.yml
  echo mkdir -p "${PWD}/uptime-kuma-data"|ssh -o StrictHostKeyChecking=no "${NODE_NAME}"
fi
kubectl apply -f uptime-kuma.pv.yml

# Wait for pod to be running
until kubectl get pod -n ${UPTIME_KUMA_NAMESPACE} | grep 1/1; do
  sleep 5
done

# Set up port-forward
kubectl port-forward service/uptime-kuma-service -n uptime-kuma --address "${UPTIME_IP}" 3001:3001 &

# Get name of pod for copying files to and executing things on
UPTIME_POD=$(kubectl get pod -n ${UPTIME_KUMA_NAMESPACE} | grep 1/1 | cut -d\  -f1)

# Copy the python code to the pod
kubectl cp requirements.txt "${UPTIME_POD}":/root/ -n "${UPTIME_KUMA_NAMESPACE}"
kubectl cp python/create_user.py "${UPTIME_POD}":/root/ -n "${UPTIME_KUMA_NAMESPACE}"
kubectl cp python/create_monitors.py "${UPTIME_POD}":/root/ -n "${UPTIME_KUMA_NAMESPACE}"
kubectl cp monitors.json "${UPTIME_POD}":/app/ -n "${UPTIME_KUMA_NAMESPACE}"

# Update the pod and install firefox
kubectl exec pod/"${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "apt-get update"
kubectl exec pod/"${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "apt-get install -y firefox-esr"

# Now install requirements.txt & run the python to create user
kubectl exec -t "${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "pip3 install -r ~/requirements.txt"
kubectl exec -t "${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "export UPTIME_USERNAME=$UPTIME_USERNAME; export UPTIME_PASSWORD=$UPTIME_PASSWORD; python3 ~/create_user.py"

# Create monitors
kubectl exec -t "${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "pip3 install uptime_kuma_api"
kubectl exec -t "${UPTIME_POD}" -n "${UPTIME_KUMA_NAMESPACE}" -- sh -c "export UPTIME_URL=http://0.0.0.0:3001; export UPTIME_USERNAME=$UPTIME_USERNAME; export UPTIME_PASSWORD=$UPTIME_PASSWORD; python3 ~/create_monitors.py"


#!/bin/bash

#kind create cluster --config k8s.yaml --name melissa
#sleep 20s
#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#sleep 10s
#kubectl label nodes melissa-worker role=worker
#kubectl label nodes melissa-worker2 role=worker
#kubectl label nodes melissa-worker3 role=worker
#kubectl label nodes melissa-worker4 role=worker
#kubectl label nodes melissa-worker5 role=worker
#kubectl label nodes melissa-worker6 role=worker

set -euxo pipefail

# Create the cluster
kind create cluster --config k8s.yaml --name melissa
sleep 20s

# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sleep 10s

# Patch metrics-server to use --kubelet-insecure-tls
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value":"--kubelet-insecure-tls"}]'

# Label the first worker manually
kubectl label nodes melissa-worker role=worker --overwrite

# Label the remaining worker nodes
for i in {2..6}; do
  kubectl label nodes melissa-worker$i role=worker --overwrite
done

#Taint workers so only pods with matching toleration can run
for i in {4..6}; do
  kubectl taint nodes melissa-worker$i dedicated=autoscaler:NoSchedule --overwrite
done

#Cordon them so no new pods can schedule unless toleration exists
for i in {4..6}; do
  kubectl cordon melissa-worker$i
done

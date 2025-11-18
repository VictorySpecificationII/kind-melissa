# KinD-melissa

You can either read it as the greek word for bee, or the name.

This repository houses an implementation for a Kubernetes-in-Docker HA cluster. 
You can use this to spin up and tear down a quick cluster for learning and development.
It disables the native CNI and replaces it with Cilium.
It comes bundled with `kube-metrics` so you can have basic observability for your cluster.

## Prerequisites

For this to work, you need `kind` and `kubectl`. Follow the instructions to install them on your operating system.

### KinD
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

## Usage
 - Run `chmod +x spin_up.sh`
 - Run `chmod +x tear_down.sh`
 - To spin up, run `./spin_up.sh`
 - To tear down, run `./tear_down.sh`
 - To view cluster load, run `kubectl top node`

## Install Cilium

Once your cluster is online, install Cilium
```
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.18.4 --namespace kube-system --set image.pullPolicy=IfNotPresent --set ipam.mode=kubernetes
```

Now you can go ahead and test it works by deploying some pods.
```
kubectl create ns cilium-test
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/1.18.4/examples/kubernetes/connectivity-check/connectivity-check.yaml
```


Give it a minute or two, then
```
kubectl get pods -n cilium-test
```
should show all the pods running. You know Cilium is working in your cluster.

You can go ahead and delete the namespace.
```
kubectl delete ns cilium-test
```

## Install Cilium CLI

Copy and paste the following into your terminal:

```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

Once it's installed, run `cilium status` to see the status of your CNI.

## Cool Stuff to experiment with

 - https://github.com/run-ai/fake-gpu-operator | Emulating GPU clusters without physical hardware
 - https://github.com/canonical/microceph | HPC storage supporting block, file and S3
 - https://github.com/SlinkyProject/slurm-operator | SLURM on Kubernetes
